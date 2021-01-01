import SwiftUI

struct SegmentedActivityIndicator: View {
	struct Segment: Shape {
		// MARK: - PROPERTIES
		// MARK: Type properties
		private static let padding: CGFloat = 12.0
		
		// MARK: Stored properties
		let segmentIndex: Int
		let maxSegmentCount: Int
		
		// MARK: - METHODS
		// MARK: Shape methods
		func path(in rect: CGRect) -> Path {
			let segmentDegrees = 360 / maxSegmentCount
			let centrePoint = CGPoint(x: rect.midX, y: rect.midY)
			var path = Path()
			
			let startDegree = Double(((segmentDegrees * segmentIndex) + 270) % 360)
			let endDegree = Double(((segmentDegrees * (segmentIndex + 1)) + 270) % 360)
			
			path.move(to: centrePoint)
			path.addArc(center: centrePoint, radius: rect.midX - Self.padding, startAngle: Angle(degrees: startDegree), endAngle: Angle(degrees: endDegree), clockwise: false)
			path.closeSubpath()
			
			return path
		}
	}
	
	
	// MARK: - PROPERTIES
	// MARK: Type properties
	static let defaultWidth: CGFloat = 100.0
	
	// MARK: Stored properties
	let completedSegmentCount: Int
	let maxSegmentCount: Int
	
	// MARK: View properties
	var body: some View {
		ZStack {
			ForEach(0..<maxSegmentCount) { segmentIndex in
				let segmentFillColor: UIColor = (segmentIndex < completedSegmentCount) ? .white : .systemGray4
				
				Segment(segmentIndex: segmentIndex, maxSegmentCount: maxSegmentCount)
					.fill(Color(segmentFillColor))
				
				Segment(segmentIndex: segmentIndex, maxSegmentCount: maxSegmentCount)
					.stroke(Color(.systemGroupedBackground), lineWidth: 4.0)
			}
		}
	}
}
