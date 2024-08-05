//
//  ThankYouView.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import SwiftUI
import SDWebImageSwiftUI

struct ThankYouView: View {
    @Environment(\.router) var mainRouter
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hasTimeElapsed = false
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).ignoresSafeArea()
            VStack {
                LottieView(animationFileName: "complete", loopMode: .playOnce)
                    .frame(width: hasTimeElapsed ? 250 : 400, height:  hasTimeElapsed ? 200: 350)
                    .offset(x: 0, y: hasTimeElapsed ? 0 : 20)
                Text(hasTimeElapsed ? "Thanks for taking\n the survey." : "")
                    .textStyle(Display2TextStyle())
                    .multilineTextAlignment(.center)
            }
            .animation(.easeOut, value: hasTimeElapsed)
        }
        .task {
            await delayAnimation()
        }
        .task {
            await delayPopOut()
        }
        
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden()
        
    }
    
    private func delayAnimation() async {
        // 1 second = 1_000_000_000 nanoseconds
        // took 3 second for the animation to finish
        try? await Task.sleep(nanoseconds: 3_000_000_000)
        hasTimeElapsed = true
    }
    
    private func delayPopOut() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        mainRouter.dismissScreen()
    }
    
}

#Preview {
    ThankYouView()
}
