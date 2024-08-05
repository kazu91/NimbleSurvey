//
//  HomeView.swift
//  NimbleSurvey
//
//  Created by Kazu on 1/8/24.
//

import SwiftUI
import SDWebImageSwiftUI
import SwiftfulRouting

struct HomeView: View {
    @Environment(\.router) var mainRouter
    
    @StateObject var userViewModel: UserViewModel
    @StateObject var homeViewModel: HomeViewViewModel
    
    let avatarheight: CGFloat = 48
    let dotSize: CGFloat = 8
    
    var inactiveTine = Color.gray.opacity(0.7)
    var activeTint = Color.white
    
    var body: some View {
        
        VStack {
            if homeViewModel.isLoading {
                SkeletonLoadingHomeView()
                
            } else {
                if homeViewModel.surveys.isEmpty {
                    Button("Back to login screen") {
                        mainRouter.dismissScreen()
                    }
                } else {
                    GeometryReader { proxy in
                        ZStack {
                            WebImage(url: URL(string: homeViewModel.surveys[homeViewModel.currentPageIndex - 1].attributes.coverImageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: proxy.size.width, height: proxy.size.height)
                            } placeholder: {
                                Rectangle().foregroundColor(.gray)
                            }
                            .animation(.easeInOut, value: homeViewModel.currentPageIndex)
                            
                            
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
                            
                        }
                    }
                    .ignoresSafeArea(.all)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < 0 {
                    if homeViewModel.currentPageIndex == homeViewModel.surveys.count {
                        return
                    }
                    homeViewModel.currentPageIndex += 1
                }
                
                if value.translation.height < 0 {
                    // up
                }
                
                if value.translation.height > 0 {
                    // down
                }
                
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
        .onChange(of: userViewModel.isShowingError, { _, newValue in
            if newValue {
                mainRouter.showBasicAlert(text: userViewModel.message)
                {
                    userViewModel.isShowingError = false
                }
            }
        })
        // load next page
        .onChange(of: homeViewModel.currentPageIndex , { _ , newValue in
            if homeViewModel.currentPageIndex == homeViewModel.surveys.count - 1 &&  homeViewModel.canLoadNextPage {
                Task {
                    homeViewModel.page += 1
                    await homeViewModel.getSurveyList()
                }
            }
        })
        .onAppear {
            Task {
                homeViewModel.isLoading = true
                await userViewModel.getUserInfo()
                await homeViewModel.getSurveyList()
                homeViewModel.isLoading = false
            }
        }
        
    }
    
    
    // MARK: - View
    
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
        
        HStack {
            withAnimation {
                ForEach(1...homeViewModel.surveys.count, id: \.self) { index in
                    Capsule(style: .circular)
                        .fill(index == homeViewModel.currentPageIndex ? activeTint : inactiveTine)
                        .frame(width: (index == homeViewModel.currentPageIndex) ? dotSize * 2 : dotSize, height: dotSize)
                        .animation(.easeInOut, value: homeViewModel.currentPageIndex)
                }
            }
        }
        .frame(height: 44)
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
            Text(homeViewModel.surveys[homeViewModel.currentPageIndex - 1].attributes.description)
                .textStyle(ParagraphTextStyle())
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(.horizontal, 20)
        .animation(.default, value: homeViewModel.currentPageIndex)
    }
}

#Preview {
    RouterView { _ in
        HomeView(userViewModel: UserViewModel(userService: UserService()), homeViewModel: HomeViewViewModel())
    }
    
}
