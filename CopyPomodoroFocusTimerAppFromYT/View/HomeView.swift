//
//  ContentView.swift
//  CopyPomodoroFocusTimerAppFromYT
//
//  Created by july on 2023/4/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ViewModel
    @State private var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            Text("Pomodoro Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
            GeometryReader { geometry in
                VStack(spacing: 15) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.03))
                            .padding(-40)
                        
                        Circle()
                            .trim(from: 0,to: viewModel.progress)
                            .stroke(.white.opacity(0.03),lineWidth: 80) //opacity = 0.03
                        
                        // MARK: Shadow
                        Circle()
                            .stroke(Color("Purple"),lineWidth:5)
                            .blur(radius: 15)
                            .padding(-2)
                        
                        Circle()
                            .fill(Color("BG"))
                        
                        Circle()
                            .trim(from: 0,to: viewModel.progress)
                            .stroke(Color("Purple").opacity(0.7),lineWidth:10)

                        //MARK: Knob
                        GeometryReader { geometry in
                            let size = geometry.size
                            Circle()
                                .fill(Color("Purple"))
                                .frame(width: 30,height: 30)
                                .overlay {
                                    Circle()
                                        .fill(.white)
                                        .padding(5)
                                }
                                .frame(width: size.width,height: size.height,alignment: .center)
                                .offset(x: size.height/2)
                                .rotationEffect(.init(degrees: viewModel.progress * 360))
                        }
                        Text(viewModel.timeStringValue)
                            .font(.system(size: 45,weight: .light))
                            .rotationEffect(.init(degrees: 90))
                            .animation(.none, value: viewModel.progress)
                        
                    }
                    .padding(60)
                    .frame(height: geometry.size.width)
                    .rotationEffect(.init(degrees: -90))
                    .animation(.easeInOut, value: viewModel.progress)
                    .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
                    Button {
                        if viewModel.isStarted {
                            viewModel.stopTimer()
                            // MARK: - cancel all notifications
                            UNUserNotificationCenter.current()
                                .removeAllPendingNotificationRequests()

                        } else {
                            viewModel.addNewTimer = true
                        }
                    } label: {
                        Image(systemName: !viewModel.isStarted ? "timer" : "stop.fill")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)
                            .frame(width: 80,height: 80)
                            .background {
                                Circle()
                                    .fill(Color("Purple"))
                            }
                            .shadow(color: Color("Purple"), radius: 8,x: 0,y: 0)
                    }
                }
                .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .center)
            }
        }
        .padding()
        .background {
            Color("BG")
                .ignoresSafeArea(.all)
        }
        .overlay(content: {
            ZStack {
                Color.black
                    .opacity(viewModel.addNewTimer ? 0.25 : 0)
                    .onTapGesture {
                        viewModel.hour = 0
                        viewModel.minute = 0
                        viewModel.seconds = 0
                        viewModel.addNewTimer = false
                    }
                NewTimerView()
                    .frame(maxHeight: .infinity,alignment: .bottom)
                    .offset(y: viewModel.addNewTimer ? 0 : 400)
            }
            .animation(.easeInOut, value: viewModel.addNewTimer)
        })
        .preferredColorScheme(.dark)
        .onReceive(timer) { _ in
            if viewModel.isStarted {
                viewModel.updateTimer()
            }
        }
        .alert("Congratulations you did it hooray ❤️",isPresented: $viewModel.isFinished) {
            Button("Start New",role: .cancel) {
                viewModel.stopTimer()
                viewModel.addNewTimer = true
            }
            Button("Close",role: .destructive){
                viewModel.stopTimer()
            }
        }
    }
    
    //MARK: New Timer Bottom Sheet
    @ViewBuilder
    func NewTimerView()-> some View {
        VStack(spacing: 15) {
            Text("Add New Timer")
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.top,10)
            HStack {
                Text("\(viewModel.hour) hr")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,20)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu {
                        ContextMenuOptions(maxValue: 12, hint: "hr") { value in
                            viewModel.hour = value
                        }
                    }
                
                Text("\(viewModel.minute) min")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,20)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu {
                        ContextMenuOptions(maxValue: 60, hint: "min") { value in
                            viewModel.minute = value
                        }
                    }
                Text("\(viewModel.seconds) sec")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.3))
                    .padding(.horizontal,20)
                    .padding(.vertical,20)
                    .background {
                        Capsule()
                            .fill(.white.opacity(0.07))
                    }
                    .contextMenu {
                        ContextMenuOptions(maxValue: 60, hint: "sec") { value in
                            viewModel.seconds = value
                        }
                    }
            }
            .padding(.top,20)
            
            Button {
                viewModel.startTimer()
            } label: {
                Text("Save")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical)
                    .padding(.horizontal,100)
                    .background {
                        Capsule()
                            .fill(Color("Purple"))
                    }
            }
            .disabled(viewModel.seconds == 0 )
            .opacity(viewModel.seconds == 0 ? 0.5 : 1)
            .padding(.top)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 10,style: .continuous)
                .fill(Color("BG"))
                .ignoresSafeArea()
        }
    }
    
    //MARK: Reusable context menu options
    @ViewBuilder
    func ContextMenuOptions(maxValue: Int,hint: String,onClick: @escaping (Int)->()) -> some View{
        ForEach(0...maxValue, id: \.self) {value in
            Button("\(value)\(hint)") {
                onClick(value)
            }
        }
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ViewModel())
    }
}
