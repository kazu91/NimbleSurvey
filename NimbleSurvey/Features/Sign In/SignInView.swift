//
//  SignInView.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import SwiftUI

struct SignInView: View {
    
    @State var emailText = ""
    @State var passwordText = ""
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                
                backgroundView
                
                gradient
                
                VStack {
                    Image("nimbleLogo")
                        .padding(.vertical, 130)
                    VStack(spacing: 15) {
                        
                        emailTextfield
                        
                        passwordTextfield
                        
                        Button {
                            
                        } label: {
                            Text("Sign In")
                                .foregroundColor(.black)
                                .font(.system(size: 17))
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, maxHeight: 52)
                                .background( RoundedRectangle(cornerRadius: 26.0).fill(.white))
                        }
                        .buttonStyle(.automatic)
                        
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            
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
            .blur(radius: 20)
            .padding(-20)
    }
    
    var emailTextfield: some View {
        TextField("", text: $emailText, prompt: Text("Email").foregroundColor(.white.opacity(0.5)))
            .modifier(TextFieldModifier(fontSize: 16,
                                        backgroundColor: .white.opacity(0.15),
                                        textColor: .white,
                                        height: 52))
    }
    
    var passwordTextfield: some View {
        SecureField("", text: $passwordText, prompt: Text("Password").foregroundColor(.white.opacity(0.5)))
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
    
}
#Preview {
    SignInView()
}
