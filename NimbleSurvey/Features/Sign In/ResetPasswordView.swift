//
//  ResetPasswordView.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import Foundation
import SwiftUI

struct ResetPasswordView: View {
    
    @State var emailText: String = ""
    
    var body: some View {
        NavigationStack {
           
            ZStack {
                backgroundView
                
                gradient
                
                VStack {
                    VStack(spacing: 24) {
                        Image("nimbleLogo")
                        
                        Text("Enter your email to receive instructions for resetting your password.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .light))
                    }
                    .padding(.vertical, 130)
                    
                    VStack(spacing: 16) {
                        
                        emailTextfield
                        
                        Button {
                            // action
                        } label: {
                            Text("Reset")
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
            .customBackButton()
           
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
}


#Preview {
    ResetPasswordView()
}
