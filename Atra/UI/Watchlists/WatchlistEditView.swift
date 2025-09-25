//
//  WatchlistEditView.swift
//  Atra
//
//  Created by Daniel Velikov on 8.09.25.
//

import SwiftUI

struct WatchlistEditView: View {
    enum Variant {
        case create
        case edit(UUID)
        
        var primaryButtonTitle: String {
            switch self {
            case .create: "Create"
            case .edit: "Update"
            }
        }
        
        var inputText: String {
            switch self {
            case .create: ""
            case .edit(let value): value.uuidString
            }
        }
    }
    
    private let variant: Variant
    @State private var input: String = ""
    
    init(variant: Variant) {
        self.variant = variant
        self.input = variant.inputText
    }
    
    private var promtView: Text {
        Text("Enter watchlist name...")
            .foregroundStyle(.secondaryText)
    }
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("", text: $input, prompt: promtView)
                .font(.secondary, size: .title)
                .foregroundStyle(Color.primaryText)
            
            Spacer()
            Spacer()
            
            HStack {
                Button {
                    print("OK")
                } label: {
                    Text(variant.primaryButtonTitle)
                        .font(.primary, size: .headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandGreen)
                
                Button {
                    print("Cancel")
                } label: {
                    Text("Cancel")
                        .font(.primary, size: .headline)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.accentGray)
            }
            
            Spacer()
        }
        .padding(20)
        .presentationBackground(Color.background)
    }
}

#Preview {
    WatchlistEditView(variant: .edit("123 Sample"))
}
