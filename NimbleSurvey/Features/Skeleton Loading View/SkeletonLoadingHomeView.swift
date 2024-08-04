//
//  SkeletonLoadingHomeView.swift
//  NimbleSurvey
//
//  Created by Kazu on 1/8/24.
//

import SwiftUI

struct SkeletonLoadingHomeView: View {
        
    let frameHeight: CGFloat = 20
    var body: some View {
        VStack {
            HStack {
                VStack {
                    ShimmerAnimatedView()
                        .frame(height: frameHeight)
                        .cornerRadius(frameHeight / 2)
                        .padding(.bottom, 10)
                    ShimmerAnimatedView()
                        .frame(height: frameHeight)
                        .cornerRadius(frameHeight / 2)
                        .padding(.trailing, 30)
                }
                .padding(.trailing, 150)
                
                
                ShimmerAnimatedView()
                    .frame(width: 50, height: 50)
                    .cornerRadius(25)
                
                
            }
            .padding()
            Spacer()
            
            VStack(alignment: .leading) {
                ShimmerAnimatedView()
                    .frame(width: 40, height: frameHeight)
                    .cornerRadius(frameHeight / 2)
                    .padding(.bottom, 10)
                
                VStack(spacing: 0) {
                    ShimmerAnimatedView()
                        .frame(height: frameHeight)
                        .cornerRadius(frameHeight / 2)
                        .padding(.bottom, 10)
                    ShimmerAnimatedView()
                        .frame(height: frameHeight)
                        .cornerRadius(frameHeight / 2)
                        .padding(.trailing, 50)
                }
                .padding(.trailing, 100)
                
                
                VStack(spacing: 0) {
                    ShimmerAnimatedView()
                        .frame(height: frameHeight)
                        .cornerRadius(frameHeight / 2)
                        .padding(.bottom, 10)
                    ShimmerAnimatedView()
                        .frame(height: frameHeight)
                        .cornerRadius(frameHeight / 2)
                        .padding(.trailing, 30)
                }
                .padding(.trailing, 40)
                .padding(.top, 16)
                
                
            }
            .padding()
        }
        .background(Color.black)
    }
   
}


#Preview {
    SkeletonLoadingHomeView()
}
