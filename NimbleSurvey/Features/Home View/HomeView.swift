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
    
    @State var currentPageIndex = 1
    
    let avatarheight: CGFloat = 48
    let dotSize: CGFloat = 8
    
    var inactiveTine = Color.gray.opacity(0.7)
    var activeTint = Color.white
    
    let titles = ["Working from home Check-In", "Career training and development", "Inclusion and belonging"]
    let messages = ["We would like to know what are your goals and skills you wanted", "Building a workplace culture that prioritizes belonging and inclusio", "We would like to know how you feel about our work from home"]
    
    var body: some View {
        ZStack {
            Image("authBgImage")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0)  {
                headerView()
                    .safeAreaPadding(.top, 32)
                    
                
                Spacer()
                
                pagingView()
                
                VStack {
                    VStack(spacing: 12) {
                        Text(titles[currentPageIndex - 1])
                            .textStyle(Display2TextStyle())
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .frame(height: 68)
                        Text(messages[currentPageIndex - 1])
                            .textStyle(ParagraphTextStyle())
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    .padding(.horizontal, 20)
                    .animation(.default, value: currentPageIndex)
                    
                    Button("Take This Survey") {
                        mainRouter.showScreen(.fullScreenCover) { _ in
                            ThankYouView()
                        }
                    }
                    .buttonStyle(CapsuleButton())
                    .padding()
                }
                .safeAreaPadding(.bottom, 36)
            }
        }
        .navigationBarBackButtonHidden()
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < 0 {
                    currentPageIndex += 1
                }
                
                if value.translation.width > 0 {
                    if currentPageIndex == 1 {
                        return
                    }
                    currentPageIndex -= 1
                }
            }))
        
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
            
            WebImage(url: URL(string: "https://picsum.photos/200"))
                .resizable()
                .frame(width: avatarheight, height: avatarheight)
                .cornerRadius(avatarheight / 2)
                .padding()
        }
        .background(Color.white.opacity(0.3))
        .cornerRadius(25)
        .padding()
        .onTapGesture {
            mainRouter.showModal(transition: .move(edge: .leading), animation: .easeInOut, alignment: .leading, backgroundColor: Color.black.opacity(0.35), ignoreSafeArea: true) {
                modalView()
            }
        }
    }
    
    func modalView() -> some View {
        VStack(alignment: .leading,spacing: 0) {
            HStack {
                Text("Name")
                    .textStyle(LargeTitleTextStyle())
                Spacer(minLength: 0)
                WebImage(url: URL(string:  "https://picsum.photos/200"))
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
                mainRouter.dismissScreen()
            } label: {
                Text("Logout")
                    .textStyle(MediumLinkTextStyle())
            }
            
            .padding()
            
            Spacer()
        }
        .frame(maxHeight: .infinity)
        .frame(width: 250)
        .background(.black.opacity(0.9))
        .onTapGesture {
            mainRouter.dismissModal()
        }
    }
    
    func pagingView() -> some View {
        HStack {
            withAnimation {
                ForEach(1...3, id: \.self) { index in
                    Capsule(style: .circular)
                        .fill(index == currentPageIndex ? activeTint : inactiveTine)
                        .frame(width: (index == currentPageIndex) ? dotSize * 2 : dotSize, height: dotSize)
                        .animation(.easeInOut, value: currentPageIndex)
                }
            }
        }
        .frame(height: 44)
    }
}

#Preview {
    RouterView { _ in
        HomeView()
    }
   
}
