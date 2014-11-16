public class Bowling {
    lazy var frames:[Frame] = {
        return [
            Frame(game:self), Frame(game:self), Frame(game:self), Frame(game:self), Frame(game:self),
            Frame(game:self), Frame(game:self), Frame(game:self), Frame(game:self), Frame(game:self),
        ]
    }()
    
    var currentFrame:Int = -1
    
    public var Score:Int {
        let frameScores = self.frames.map({(frame:Frame) -> Int in frame.Score})
        return frameScores.reduce(0, +)
    }
    
    public func scoreFrame(firstRoll:Int, secondRoll:Int) {
        nextFrame()
            .firstRoll(firstRoll)
            .secondRoll(secondRoll)
    }
    
    public func registerAsObserverOfNextFrameRolls(observer:Frame) {
        peekNextFrame().registerObserver(observer)
    }
    
    private func nextFrame() -> Frame {
        ++currentFrame
        return frames[currentFrame]
    }
    
    private func peekNextFrame() -> Frame {
        return frames[currentFrame + 1]
    }
}

public class Frame {
    private let game:Bowling
    private var firstRoll = -1
    private var secondRoll = -1
    private var bonus = 0
    private var observers:[Frame] = []
    
    public init(game:Bowling) {
        self.game = game
    }
    
    public func firstRoll(knockedOutPins:Int) -> Frame {
        firstRoll = knockedOutPins
        
        if isStrike() {
            self.game.registerAsObserverOfNextFrameRolls(self)
        }
        
        self.observers.each {observer in observer.updateFirstRoll(knockedOutPins)}
        
        return self
    }
    
    public func secondRoll(knockedOutPins:Int) -> Frame {
        secondRoll = knockedOutPins
        
        if isSpare() {
            self.game.registerAsObserverOfNextFrameRolls(self)
        }
        
        self.observers.each {observer in observer.updateSecondRoll(knockedOutPins)}
        
        return self
    }
    
    public func registerObserver(frame:Frame) {
        self.observers.append(frame)
    }
    
    public func updateFirstRoll(knockedOutPins:Int) {
        bonus = knockedOutPins
    }
    
    public func updateSecondRoll(knockedOutPins:Int) {
        if isStrike() {
            bonus += knockedOutPins
        }
    }
    
    public var Score:Int {
        return FirstRoll + SecondRoll + bonus
    }
    
    private func isStrike() -> Bool {
        return firstRoll == 10
    }
    
    private func isSpare() -> Bool {
        return firstRoll + secondRoll == 10 && secondRoll != 0
    }
    
    private var FirstRoll:Int {
        return firstRoll > 0 ? firstRoll : 0
    }
    
    private var SecondRoll:Int {
        return secondRoll > 0 ? secondRoll : 0
    }
}

extension Array {
    func each(closure: (T) -> Void) {
        for element:T in self {
            closure(element)
        }
    }
}

let game = Bowling()
game.scoreFrame(1, secondRoll: 4)
game.scoreFrame(4, secondRoll: 5)
game.scoreFrame(6, secondRoll: 4)
game.scoreFrame(5, secondRoll: 5)
game.scoreFrame(10, secondRoll: 0)
game.scoreFrame(0, secondRoll: 1)

game.frames[0].Score
game.frames[1].Score
game.frames[2].Score
game.frames[3].Score
game.frames[4].Score
game.frames[5].Score

game.Score
