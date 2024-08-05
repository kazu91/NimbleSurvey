//
//  ResetPasswordView.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import Foundation
import SwiftUI
import SwiftfulRouting

struct ResetPasswordView: View {
    @Environment(\.router) var router
    @StateObject var userViewModel = UserViewModel(userService: UserService())
    @State var emailText: String = ""
    
    var body: some View {
        ZStack {
            backgroundView
            
            gradient
            
            VStack {
                VStack(spacing: 24) {
                    Image("nimbleLogo")
                    
                    Text("Enter your email to receive instructions for resetting your password.")
                        .textStyle(ParagraphTextStyle())
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 130)
                
                VStack(spacing: 16) {
                    
                    emailTextfield
                    
                    Button("Reset") {
                        Task {
                            await userViewModel.forgetPassword(email: emailText)
                            
                            router.showModal(transition: .move(edge: .top), animation: .easeInOut, alignment: .top, backgroundColor: Color.black.opacity(0.001), ignoreSafeArea: true) {
                                HStack(alignment: .top) {
                                    Image(systemName: userViewModel.isShowingError ? "exclamationmark.triangle" :"bell.fill")
                                        .foregroundStyle(.white)
                                    VStack(alignment: .leading) {
                                        Text(userViewModel.isShowingError ? userViewModel.message : "Check your email")
                                            .font(.system(size: 15, weight: .bold))
                                            .foregroundStyle(.white)
                                        Text(userViewModel.message)
                                            .font(.system(size: 13, weight: .regular))
                                            .multilineTextAlignment(.leading)
                                            .lineLimit(2)
                                            .foregroundStyle(.white)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 90, alignment: .bottom)
                                .padding()
                                .background(Color.init(uiColor: UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)))
                                .onTapGesture {
                                    router.dismissModal()
                                }
                            }
                        }
                    }
                    .buttonStyle(CapsuleButton())
                    .frame(maxHeight: 52)
                    
                }
                Spacer()
            }
            .padding(.horizontal)
        }
        .customBackButton()
    }
    
    // MARK: - Views
    let gradient = LinearGradient(
        gradient: Gradient(stops: [
            .init(color: .black, location: 0.3),
            .init(color: .clear, location: 1)
        ]),
        startPoint: .bottom,
        endPoint: .top
    )
    
    var backgroundView: some View {
        Image("authBgImage")
            .resizable()
            .scaledToFill()
            .frame(minWidth: 0)
            .edgesIgnoringSafeArea(.all)
            .blur(radius: 20)
            .padding(-20)
    }
    
    var emailTextfield: some View {
        TextField("", text: $emailText, prompt: Text("Email").foregroundColor(.white.opacity(0.5)))
            .textInputAutocapitalization(.never)
            .modifier(TextFieldModifier(fontSize: 16,
                                        backgroundColor: .white.opacity(0.15),
                                        textColor: .white,
                                        height: 52))
    }
}


#Preview {
    RouterView { _ in
        ResetPasswordView()
    }
}
