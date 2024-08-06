//
//  SurveyModel.swift
//  NimbleSurvey
//
//  Created by Kazu on 3/8/24.
//

import SwiftData

// MARK: - Survey
@Model class SurveyListModel: Codable {
    enum CodingKeys: CodingKey {
        case data, meta
    }
    
    let data: [SurveyData]
    let meta: SurveyMetaData
    
    init(data: [SurveyData], meta: SurveyMetaData) {
        self.data = data
        self.meta = meta
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        meta = try container.decode(SurveyMetaData.self, forKey: .meta)
        data = try container.decode([SurveyData].self, forKey: .data)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(meta, forKey: .meta)
        try container.encode(data, forKey: .data)
    }
}

@Model class SurveyData: Codable {
    let id: String
    let type: String
    var attributes: Survey
    
    enum CodingKeys: CodingKey {
        case id, type, attributes
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(String.self, forKey: .type)
        attributes = try container.decode(Survey.self, forKey: .attributes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(attributes, forKey: .attributes)
    }
    
}

// MARK: - Attributes
@Model class Survey: Codable {
    let title: String
    let secondTitle: String
    let isActive: Bool
    let coverImageURL: String
    let createdAt: String
    let activeAt: String
    let surveyType: String
    let inactiveAt:  String?
    let thankEmailAboveThreshold:  String?
    let thankEmailBelowThreshold: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case secondTitle = "description"
        case thankEmailAboveThreshold = "thank_email_above_threshold"
        case thankEmailBelowThreshold = "thank_email_below_threshold"
        case isActive = "is_active"
        case coverImageURL = "cover_image_url"
        case createdAt = "created_at"
        case activeAt = "active_at"
        case inactiveAt = "inactive_at"
        case surveyType = "survey_type"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        secondTitle = try container.decode(String.self, forKey: .secondTitle)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        coverImageURL = try container.decode(String.self, forKey: .coverImageURL)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        activeAt = try container.decode(String.self, forKey: .activeAt)
        inactiveAt = try container.decode(String?.self, forKey: .inactiveAt)
        surveyType = try container.decode(String.self, forKey: .surveyType)
        thankEmailAboveThreshold = try container.decode(String?.self, forKey: .thankEmailAboveThreshold)
        thankEmailBelowThreshold = try container.decode(String?.self, forKey: .thankEmailBelowThreshold)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(secondTitle, forKey: .secondTitle)
        try container.encode(isActive, forKey: .isActive)
        try container.encode(coverImageURL, forKey: .coverImageURL)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(activeAt, forKey: .activeAt)
        try container.encode(inactiveAt, forKey: .inactiveAt)
        try container.encode(surveyType, forKey: .surveyType)
        try container.encode(thankEmailAboveThreshold, forKey: .thankEmailAboveThreshold)
        try container.encode(thankEmailBelowThreshold, forKey: .thankEmailBelowThreshold)
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

