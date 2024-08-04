//
//  SignInView.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import SwiftUI
import SwiftfulRouting

struct SignInView: View {
    @Environment(\.router) var router: AnyRouter
    @StateObject var viewModel: SignInViewModel
    
    @State var emailText = ""
    @State var passwordText = ""
    
    @State var finishFirstStageAnimation = false
    @State var finishSecondStageAnimation = false
    
    let logoPadding: CGFloat = 130
    let logoHeight: CGFloat = 96
    
    
    // MARK: - Body
    var body: some View {
        ZStack {
            backgroundView
            
            if finishSecondStageAnimation {
                gradient
            }
               
            GeometryReader { geometry in
                VStack {
                    Image("nimbleLogo")
                        .padding(.vertical, 130)
                        .offset(x: 0,
                                y: finishSecondStageAnimation ? 0
                                : (geometry.size.height / 2) - (logoHeight / 2) - logoPadding
                        )
                    
                    if finishSecondStageAnimation {
                        VStack(spacing: 15) {
                            
                            emailTextfield
                            
                            passwordTextfield
                            
                            Button("Sign In") {
                                Task {
                                   await viewModel.signIn()
                                    
                                }
                               
                            }
                            .buttonStyle(CapsuleButton())
                            .disabled(viewModel.isLoading || viewModel.isNotValid)
                            .frame(maxHeight: 52)
                        }
                    }
                    Spacer()
                    
                }
                . frame(maxWidth: .infinity)
                .animation(.easeInOut, value: finishSecondStageAnimation)
                .animation(.easeOut(duration: 3), value: finishSecondStageAnimation)
                .padding(.horizontal)
            }
            
            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .controlSize(.large)
                        .progressViewStyle(.circular)
                }
                
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .cornerRadius(40)
                .background(.black.opacity(0.9))
                
            }
        }
        .onChange(of: viewModel.isShowingError, { _, newValue in
            if newValue {
                router.showBasicAlert(text: viewModel.errorMessage)
            }
        })
        .task {
            await executeFirstAnimationTimer()
            // if logged in exec only first
            await executeSecondAnimationTimer()
        }
        
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
            .blur(radius: finishSecondStageAnimation ? 20 : 0)
            .padding(-20)
    }
    
    var emailTextfield: some View {
        TextField("", text: $viewModel.email, prompt: Text("Email").foregroundColor(.white.opacity(0.5)))
            .textInputAutocapitalization(.never)
            .modifier(TextFieldModifier(fontSize: 16,
                                        backgroundColor: .white.opacity(0.15),
                                        textColor: .white,
                                        height: 52))
    }
    
    var passwordTextfield: some View {
        SecureField("", text: $viewModel.password, prompt: Text("Password").foregroundColor(.white.opacity(0.5)))
            .privacySensitive()
            .modifier(TextFieldModifier(fontSize: 16,
                                        backgroundColor: .white.opacity(0.15),
                                        textColor: .white,
                                        height: 52))
            .overlay(alignment: .trailing) {
                NavigationLink {
                    ResetPasswordView()
                } label: {
                    Text("Forgot?")
                        .foregroundStyle(.white)
                        .padding(.trailing, 18)
                }
                
            }
        
    }
    
    // MARK: - Functions
    
    private func executeFirstAnimationTimer() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        finishFirstStageAnimation = true
    }
    
    private func executeSecondAnimationTimer() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        finishSecondStageAnimation = true
    }
    
}
#Preview {
    RouterView { router in
        SignInView(viewModel: SignInViewModel(router: router))
    }
}
