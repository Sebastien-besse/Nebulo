//
//  ResponseMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 22/09/2026.
//

import Foundation

enum ResponseMapper {
    static func toDomain(_ dto: ResponseDTO) -> PostResponse {
        PostResponse(
            id: dto.id,
            content: dto.content,
            dateOfCreated: dto.dateOfCreated,
            postId: dto.postId,
            authorId: dto.authorId,
            authorFirstname: dto.authorFirstname,
            authorAge: dto.authorAge
        )
    }
}
