import Foundation


public struct MeasurementState: Equatable {
    public var progress: ProgressState
    public var dimension: Dimension
    public var availableDimensions: [Dimension]

    public init(progress: ProgressState, dimension: Dimension, availableDimensions: [Dimension] = [
        UnitLength.kilometers,
        UnitMass.kilograms
    ]) {
        self.progress = progress
        self.dimension = dimension
        self.availableDimensions = availableDimensions
    }
}

public enum MeasurementAction: Equatable {
    case progress(ProgressAction)
}



public let measurementGoalReducer = Reducer<MeasurementState, MeasurementAction, Void>.combine(
    progressReducer.pullback(state: \.progress, action: /MeasurementAction.progress, environment: { _ in () })
)
