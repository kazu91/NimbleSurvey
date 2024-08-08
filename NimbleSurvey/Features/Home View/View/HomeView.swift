//
//  HomeView.swift
//  NimbleSurvey
//
//  Created by Kazu on 1/8/24.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftfulRouting
import SwiftData

struct HomeView: View {
    @Environment(NetworkMonitor.self) var networkMonitor
    @Environment(\.router) var mainRouter
    
    @StateObject var userViewModel: UserViewModel
    @StateObject var homeViewModel: HomeViewViewModel
    
    let avatarheight: CGFloat = 48
    let dotSize: CGFloat = 8
    
    var inactiveTine = Color.gray.opacity(0.7)
    var activeTint = Color.white
    
    var body: some View {
        
        VStack {
            if homeViewModel.isFirstTimeLoading {
                SkeletonLoadingHomeView()
                
            } else {
                if homeViewModel.surveys.isEmpty {
                    contentUnavailable()
                } else {
                    GeometryReader { proxy in
                        ZStack {
                           
                            backgroundView(proxy: proxy)
                            
                            VStack(spacing: 0)  {
                                headerView()
                                    .safeAreaPadding(.top, 32)
                                
                                Spacer()
                                
                                pagingView()
                                    .frame(width: proxy.size.width)
                                
                                VStack {
                                    titleSectionView()
                                    
                                    takeSurveyButton()
                                }
                                .safeAreaPadding(.bottom, 36)
                            }
                            if homeViewModel.isLoading {
                                loadingView()
                            }
                        }
                    }
                    .ignoresSafeArea(.all)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
               
                // up
                if value.translation.height < 0 {
                }
                // down
                if value.translation.height > 50 {
                    Task {
                        await homeViewModel.refreshView()
                    }
                }
                
                // right
                if value.translation.width < 0 {
                    if homeViewModel.currentPageIndex == homeViewModel.surveys.count {
                        return
                    }
                    homeViewModel.currentPageIndex += 1
                }
                
                // left
                if value.translation.width > 0 {
                    if homeViewModel.currentPageIndex == 1 {
                        return
                    }
                    homeViewModel.currentPageIndex -= 1
                }
            }))
        .onChange(of: homeViewModel.isShowingError, { _, newValue in
            if newValue {
                mainRouter.showBasicAlert(text: homeViewModel.errorMessage)
                {
                    homeViewModel.isShowingError = false
                }
            }
        })
//        .onChange(of: userViewModel.isShowingError, { _, newValue in
//            if newValue {
//                mainRouter.showBasicAlert(text: userViewModel.message)
//                {
//                    userViewModel.isShowingError = false
//                }
//            }
//        })
        .onChange(of: homeViewModel.needToSignIn, { oldValue, newValue in
            if newValue {
                mainRouter.showBasicAlert(text: homeViewModel.errorMessage)
                {
                    Task {
                        await userViewModel.logout()
                        homeViewModel.needToSignIn = false
                        mainRouter.dismissScreen()
                    }
                }
            }
        })
        // load next page
        .onChange(of: homeViewModel.currentPageIndex , { _ , newValue in
            if homeViewModel.currentPageIndex == homeViewModel.surveys.count &&  homeViewModel.canLoadNextPage {
                Task {
                    homeViewModel.isLoading = true
                    homeViewModel.page += 1
                    await homeViewModel.getSurveyListFromServer()
                    homeViewModel.isLoading = false
                }
            }
        })
        .onAppear {
            getData()
        }
    }
    
    // MARK: - View
    
    func backgroundView(proxy: GeometryProxy) -> some View {
        WebImage(url: URL(string: homeViewModel.surveys[homeViewModel.currentPageIndex - 1].attributes.coverImageURL)) { image in
            image
                .resizable()
                .scaledToFill()
                .frame(width: proxy.size.width, height: proxy.size.height)
            
        } placeholder: {
            Rectangle().foregroundColor(.gray)
        }
        .animation(.easeInOut, value: homeViewModel.currentPageIndex)
    }
    
    func headerView() -> some View {
        HStack {
            VStack(alignment: .leading) {
                Text(Date.now.toString(dateFormat: "EEEE, MMM dd").uppercased())
                    .foregroundStyle(.white)
                    .font(.system(size: 14, weight: .semibold))
                Text("Today")
                    .textStyle(LargeTitleTextStyle())
            }
            .padding()
            
            Spacer()
            
            WebImage(url: URL(string: userViewModel.user.data?.attributes.avatarURL ?? ""))
                .resizable()
                .frame(width: avatarheight, height: avatarheight)
                .cornerRadius(avatarheight / 2)
                .padding()
        }
        .background(Color.black.opacity(0.3))
        .cornerRadius(25)
        .padding(.horizontal)
        .padding(.top, 38)
        .onTapGesture {
            mainRouter.showModal(transition: .move(edge: .leading), animation: .easeInOut, alignment: .leading, backgroundColor: Color.black.opacity(0.35), ignoreSafeArea: true) {
                modalView()
            }
        }
    }
    
    func modalView() -> some View {
        VStack(alignment: .leading,spacing: 0) {
            HStack {
                Text(userViewModel.user.data?.attributes.name ?? "User Name")
                    .textStyle(LargeTitleTextStyle())
                Spacer(minLength: 0)
                WebImage(url: URL(string: userViewModel.user.data?.attributes.avatarURL ?? ""))
                    .resizable()
                    .frame(width: avatarheight, height: avatarheight)
                    .cornerRadius(avatarheight / 2)
                    .padding()
            }
            .padding(.top, 48)
            .padding(.horizontal, 20)
            
            Divider()
                .background(.gray)
                .padding(.horizontal, 20)
            
            
            Button {
                Task {
                    await userViewModel.logout()
                    
                    mainRouter.dismissScreen()
                }
            } label: {
                Text("Logout")
                    .textStyle(MediumLinkTextStyle())
            }
            
            .padding()
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .frame(width: 250)
        .background(.black)
        .onTapGesture {
            mainRouter.dismissModal()
        }
    }
    
    func pagingView() -> some View {
        // skip first page calculation
        
        return HStack {
            if homeViewModel.currentIndexPage > 1 {
                Image(systemName: "chevron.left.circle.fill")
                    .foregroundColor(Color.white)
            }
            HStack {
                withAnimation {
                    ForEach(1...homeViewModel.capsuleCount, id: \.self) { index in
                        Capsule(style: .circular)
                            .fill(index == homeViewModel.pagingCurrentIndex ? activeTint : inactiveTine)
                            .frame(width: (index == homeViewModel.pagingCurrentIndex) ? dotSize * 2 : dotSize, height: dotSize)
                            .animation(.easeInOut, value: homeViewModel.currentPageIndex)
                    }
                }
            }
            .frame(height: 44)
            if homeViewModel.canLoadNextPage || homeViewModel.surveys.count > homeViewModel.currentIndexPage * homeViewModel.pageSize {
                Image(systemName: "chevron.right.circle.fill")
                    .foregroundColor(Color.white)
            }
           
        }
        
    }
    
    func takeSurveyButton() -> some View {
        Button("Take This Survey") {
            mainRouter.showScreen(.fullScreenCover) { _ in
                ThankYouView()
            }
        }
        .buttonStyle(CapsuleButton())
        .padding()
    }
    
    func titleSectionView() -> some View {
        VStack(spacing: 12) {
            Text(homeViewModel.surveys[homeViewModel.currentPageIndex - 1].attributes.title)
                .textStyle(Display2TextStyle())
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 68)
            Text(homeViewModel.surveys[homeViewModel.currentPageIndex - 1].attributes.secondTitle)
                .textStyle(ParagraphTextStyle())
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.horizontal, 20)
        .animation(.default, value: homeViewModel.currentPageIndex)
    }
    
    fileprivate func loadingView() -> some View {
        return VStack {
            ProgressView()
                .controlSize(.large)
                .progressViewStyle(.circular)
        }
        
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .cornerRadius(40)
        .background(.black.opacity(0.9))
    }
    
    func contentUnavailable() -> some View {
        VStack {
            ContentUnavailableView("Survey Error", systemImage: "doc.plaintext", description: Text("Cannot retrieve surveys, please try again later"))
            Button("Retry") {
                getData()
            }
            Button("Log out") {
                Task {
                    await userViewModel.logout()
                    mainRouter.dismissScreen()
                }
            }
        }
    }
    
    // MARK: - Func
    
    func getData() {
        Task {
            homeViewModel.isFirstTimeLoading = true
            homeViewModel.fetchSurveys()
            await userViewModel.getUserInfo()
            await homeViewModel.getSurveyListFromServer()
            homeViewModel.isFirstTimeLoading = false
        }
    }
}

//#Preview {
//    var networkMonitor = NetworkMonitor()
//    
//   var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            SurveyData.self,
//            Survey.self
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//        
//    return RouterView { _ in
//        HomeView(userViewModel: UserViewModel(userService: UserService()), homeViewModel: HomeViewViewModel(
//            networkMonitor: NetworkMonitor(),
//            modelContent: ModelContext(sharedModelContainer)))
//    }
//    .environment(NetworkMonitor())
//}
