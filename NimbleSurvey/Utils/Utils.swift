//
//  Utils.swift
//  NimbleSurvey
//
//  Created by Kazu on 31/7/24.
//

import Foundation
import SwiftUI

// MARK: - Constant
enum Constant {
    struct FontName {
        static let Neuzeit = "NeuzeitSLTStd-Book"
    }
    
    struct SecretKey {
        static let key = "ofzl-2h5ympKa0WqqTzqlVJUiRsxmXQmt5tkgrlWnOE"
        static let secret = "lMQb900L-mTeU-FVTCwyhjsfBwRCxwwbCitPob96cuU"
    }
    
    struct KeychainKey {
        static let accessToken = "surveyNimble_access_token"
        static let refreshToken = "surveyNimble_refresh_token"
    }
    
}

// MARK: - View Modifiers

struct TextFieldModifier: ViewModifier {
    let fontSize: CGFloat
    let backgroundColor: Color
    let textColor: Color
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(Font.system(size: fontSize))
            .foregroundColor(textColor)
            .padding(.leading)
            .frame(height: height)
            .overlay(
                RoundedRectangle(cornerRadius: height/2)
                    .strokeBorder(Color.white.opacity(0.5), style: StrokeStyle(lineWidth: 0.3))
                
            )
            .background(RoundedRectangle(cornerRadius: height/2).fill(backgroundColor))
    }
}


struct CustomBackButton: ViewModifier {
    
    @Environment(\.presentationMode) var presentationMode

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                    }
                }
            }
    }
}

struct CapsuleButton: ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold))
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(.white)
            .foregroundStyle(.black)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
            
    }
}

// MARK: - Extensions

extension Date
{
    func toString( dateFormat format  : String ) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public var hashValue: Int {
            return 0
    }

    public func hash(into hasher: inout Hasher) {
            // No-op
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}
