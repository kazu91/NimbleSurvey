//
//  SurveyModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import Foundation

// MARK: - Survey
struct SurveyListModel: Codable {
    let data: [SurveyData]
    let meta: SurveyMetaData
}

struct SurveyData: Codable {
    let id, type: String
    let attributes: Survey
}

// MARK: - Attributes
struct Survey: Codable {
    let title, description: String
    let isActive: Bool
    let coverImageURL: String
    let createdAt, activeAt: String
    let surveyType: String
    let inactiveAt, thankEmailAboveThreshold, thankEmailBelowThreshold: String?
    
    enum CodingKeys: String, CodingKey {
        case title, description
        case thankEmailAboveThreshold = "thank_email_above_threshold"
        case thankEmailBelowThreshold = "thank_email_below_threshold"
        case isActive = "is_active"
        case coverImageURL = "cover_image_url"
        case createdAt = "created_at"
        case activeAt = "active_at"
        case inactiveAt = "inactive_at"
        case surveyType = "survey_type"
    }
}

struct SurveyMetaData: Codable {
    let page, pages, pageSize, records: Int

    enum CodingKeys: String, CodingKey {
        case page, pages
        case pageSize = "page_size"
        case records
    }
}

