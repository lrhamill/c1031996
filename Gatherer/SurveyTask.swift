//
//  SurveyTask.swift
//  
//
//  Created by Liam Hamill on 09/06/2015.
//
//

import ResearchKit

public var SurveyTask: ORKOrderedTask {
    
    // N.B.
    
    var steps = [ORKStep]()
    
    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "Survey"
    instructionStep.text = "Please honestly answer the following questions about your feelings over the past 24 hours. Remember that your responses are anonymous."
    
    steps += [instructionStep]
    
    let positiveAnswers = [
        ORKTextChoice(text:"None of the Time", value: 1),
        ORKTextChoice(text:"Rarely", value: 2),
        ORKTextChoice(text:"Some of the Time", value: 3),
        ORKTextChoice(text:"Often", value: 4),
        ORKTextChoice(text:"All of the Time", value: 5),
    ]
    
    let positiveAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormatWithStyle(.SingleChoice, textChoices: positiveAnswers)
    
    
    let questions = [
        
        ORKQuestionStep(identifier: "SQ1", title: "Today, I’ve been feeling optimistic about the future.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ2", title: "Today, I’ve been feeling useful.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ3", title: "Today, I’ve been feeling interested in other people.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ4", title: "Today, I’ve had energy to spare.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ5", title: "Today, I’ve been feeling relaxed.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ6", title: "Today, I’ve been dealing with problems well.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ7", title: "Today, I’ve been thinking clearly.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ8", title: "Today, I’ve been feeling good about myself .", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ9", title: "Today, I’ve been feeling close to other people.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ10", title: "Today, I’ve been feeling confident.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ11", title: "Today, I’ve been able to make up my own mind about things .", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ12", title: "Today, I’ve been feeling loved.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ13", title: "Today, I’ve been interested in new things.", answer: positiveAnswerFormat),
        ORKQuestionStep(identifier: "SQ14", title: "Today, I’ve been feeling cheerful.", answer: positiveAnswerFormat),
        
    ]
    
    // Set questions to be non-optional
    
    for item in questions {
        item.optional = false
    }
    
    // Add questions to survey in a randomised order
    
    var indexArray = [Int]()
    indexArray += 0...(questions.count - 1)
    
    while indexArray.count > 0 {
        
        let rand = Int(arc4random_uniform(UInt32(indexArray.count)))
        let index = indexArray.removeAtIndex(rand)
        
        steps += [questions[index]]
        
    }
    
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Thank You"
    summaryStep.text = "Thank you for completing today's survey. Remember to come back next tomorrow."
    steps += [summaryStep]
    
    
    
    return ORKOrderedTask(identifier: "SurveyTask", steps: steps)
}