import SwiftUI

public struct SwipeableRow<Content: View>: View {
    let content: Content
    let onDelete: () -> Void
    @State private var isDeleting = false
    @State private var offset: CGFloat = 0
    private let deleteThreshold: CGFloat = -30
    private let deleteConfirmThreshold: CGFloat = -75
    
    // Track whether this row is being dragged
    @State private var isDragging = false
    // Notification center for broadcasting drag state
    private let dragNotification = NotificationCenter.default
    
    public init(onDelete: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.onDelete = onDelete
    }
    
    public var body: some View {
        ZStack(alignment: .leading) {
            // Delete confirmation view
            Image(systemName: "trash.fill")
                .font(.headline.bold())
                .foregroundColor(.red)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, 20)
                .padding(.vertical, 12)
                .background(Color.Neumorphic.main)
                .cornerRadius(6)
                .softInnerShadow(RoundedRectangle(cornerRadius: 6))
            
            // Main content
            content
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.Neumorphic.main)
                .cornerRadius(6)
                .softOuterShadow()
                .offset(x: offset)
                                               // Add horizontal scaling and content offset based on drag
            .scaleEffect(x: 1.0 + (offset / 200), y: 1.0) // Subtle horizontal scaling
            .offset(x: offset * 0.3) // Move content left with drag
            .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            // Check if the gesture is primarily horizontal
                            let horizontalAmount = abs(gesture.translation.width)
                            let verticalAmount = abs(gesture.translation.height)
                            
                            // Only process horizontal drags (with some tolerance)
                            guard horizontalAmount > verticalAmount && horizontalAmount > 10 else { return }
                            
                            if !isDragging {
                                isDragging = true
                                // Notify other rows to reset
                                dragNotification.post(name: .swipeableRowDragBegan, object: nil)
                            }
                            
                            let translation = gesture.translation.width
                            if translation < 0 { // Only allow left swipe
                                if translation < deleteThreshold {
                                    let extra = (translation - deleteThreshold) / 2
                                    offset = deleteThreshold + extra
                                } else {
                                    offset = translation
                                }
                            }
                        }
                        .onEnded { gesture in
                            isDragging = false
                            withAnimation(.spring()) {
                                if offset < deleteConfirmThreshold {
                                    onDelete()
                                } else if offset < deleteThreshold {
                                    offset = deleteThreshold
                                    isDeleting = true
                                } else {
                                    offset = 0
                                    isDeleting = false
                                }
                            }
                        }
                )
                .onReceive(dragNotification.publisher(for: .swipeableRowDragBegan)) { notification in
                    // Reset this row if it's not the one being dragged
                    if !isDragging {
                        withAnimation(.spring()) {
                            offset = 0
                            isDeleting = false
                        }
                    }
                }
        }
    }
}

// Notification name for drag events
extension Notification.Name {
    static let swipeableRowDragBegan = Notification.Name("swipeableRowDragBegan")
} 
