//
//  ContentView.swift
//  LineGraph
//
//  Created by Ivan Dudarev on 01.08.2022.
//

import SwiftUI

struct ContentView: View {
    
    @State private var position = 0
    
    var graphData: Array<CGFloat> = .init()
    
    init() {
        for _ in 0..<1000 {
            graphData.append(CGFloat.random(in: 0..<30))
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
        //ScrollView(.horizontal, showsIndicators: false) {
            //GeometryReader { proxy in
                HStack {
                    LineGraphView(data: graphData, geometry: geometry.size)
                        .frame(width: geometry.size.width, height: 200)
                }
            //}
        //}
        }
        .coordinateSpace(name: "scroll")
//        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
//            print(value)
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct LineGraphView: View {
    
    @State private var on: Bool = true
    
    let data: Array<CGFloat>
    let lineRadius: CGFloat
    let lineColor: Color
    
    init(data: Array<CGFloat>, lineRadius: CGFloat = 0.5, geometry: CGSize, lineColor: Color = .black) {
        self.data = data
        self.lineRadius = lineRadius
        self.lineColor = lineColor
    }
    
    private var maxYValue: CGFloat {
        let maxV = data.max() ?? 1.0
        let minV = data.min() ?? 0.0
        return maxV + abs(minV)
    }
    
    private var maxXValue: CGFloat {
        CGFloat(data.count) / 1.0
    }
    
    private var minV: CGFloat {
        data.min() ?? 0.0
    }
    
    
    @State private var offsetData: Int = 16
    @State private var startOffset: Int = 0
    
    private var getData: Array<CGFloat> {
        Array<CGFloat>(self.data[startOffset..<offsetData])
    }
    
    @GestureState var locationState = CGPoint(x: 100, y: 100)
    
    var body: some View {
        GeometryReader { geometry in
            graphBody(data: getData, size: geometry.size)
                .gesture (
                    DragGesture()
                        .onChanged { state in
                            let value = (state.startLocation.x - state.location.x)
                            print(value)
                            withAnimation(.easeInOut) {
                                if state.translation.width < 0 {
                                    if offsetData < self.data.count {
                                        self.startOffset += 1
                                        self.offsetData += 1
                                    }
                                }
                                if state.translation.width < 0 {
                                    
                                }
                            }
                        }
//                        .updating($locationState, body: { currentState, pastLocation, transaction in
//                            let value = Int(currentState.startLocation.x) - Int(currentState.location.x)
//                            self.startOffset += value
//                            self.offsetData += value
//                        })
                )
        }
    }
    
    private func maxYVal(data: Array<CGFloat>) -> CGFloat {
        let maxV = data.max() ?? 1.0
        let minV = data.min() ?? 0.0
        return maxV + abs(minV)
    }
    
    private func graphBody(data: Array<CGFloat>, size: CGSize, closed: Bool = false) -> some View {
        
        Path { path in
            path.move(to: .init(x: 0, y: size.height / 2))
            var previousPoint = CGPoint(x: 0, y: 0)
            
            var step = 0.0
            data.forEach { point in
                let x = (step / Double(data.count) / 1.0) * size.width
                let y = size.height - (size.height / maxYVal(data: data)) * (point + abs(data.min() ?? 0.0))
                
                let deltaX = x - previousPoint.x
                let curveXOffset = deltaX * self.lineRadius
                
                path.addCurve(to: .init(x: x, y: y),
                              control1: .init(x: previousPoint.x + curveXOffset, y: previousPoint.y),
                              control2: .init(x: x - curveXOffset, y: y ))
                
                previousPoint = .init(x: x, y: y)
                step += 2.0
            }
        }
        .stroke(lineColor, style: StrokeStyle(lineWidth: 2))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 1.5)) {
                    //self.offsetData += 1
                }
            }
        }
    }
}
