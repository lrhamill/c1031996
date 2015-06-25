//
//  ConsentDocument.swift
//  Gatherer
//
//  Created by Liam Hamill on 04/06/2015.
//  Copyright (c) 2015 Liam Hamill. All rights reserved.
//

import Foundation
import ResearchKit

public var consentDocument: ORKConsentDocument {

    let consentDocument = ORKConsentDocument()
    
    consentDocument.title = "Happiness Questionnaire"
    
    let consentSectionTypes: [ORKConsentSectionType] = [
        .Overview,
        .Privacy,
        .DataGathering,
        .Withdrawing
    ]
    
    
    
    var consentSections: [ORKConsentSection] = consentSectionTypes.map { contentSectionType in
        let consentSection = ORKConsentSection(type: contentSectionType)
        switch contentSectionType {
        
        case .Overview:
            consentSection.summary = "We will ask you daily questions about your mood and collect some health data."
            consentSection.content = "I understand that my participation in this project will involve spending five minutes of every day answering short questions about my current mood. This application will also periodically collect data from the system Health App."
        
        case .Privacy:
            consentSection.summary = "Your information will be anonymised and cannot be traced to you."
            consentSection.content = "I understand that the information provided by me will be held totally anonymously, so that it is impossible to trace this information back to me individually."
        
        case .DataGathering:
            consentSection.summary = "Your mood and health data will be shared with the research team and may be used in subsequent publications."
            consentSection.content = "I understand that I will be providing information about my mood while I am participating in this study. This application will also extract data about your exercise from the system Health app.\nI understand that the information I provide will be shared with the research team or research supervisor and may be used in subsequent publications. I understand that, in accordance with the Data Protection Act, this information may be retained indefinitely."
        
        case .Withdrawing:
            consentSection.summary = "You can withdraw your consent at any time."
            consentSection.content = "I understand that participation in this study is entirely voluntary and that I can withdraw from the study at any time without giving a reason. Please note that data that has already been provided and anonymised cannot be withdrawn. I understand that I can contact the research team directly via this email address: HamillLR@cardiff.ac.uk"
         
        default:
            println(contentSectionType)
        }

        return consentSection
    }
    
    consentDocument.sections = consentSections
    
    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature"))
    
    return consentDocument

}