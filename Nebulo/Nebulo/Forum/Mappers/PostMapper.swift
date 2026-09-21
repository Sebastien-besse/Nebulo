//
//  PostMapper.swift
//  Nebulo
//
//  Created by apprenant152 on 20/09/2026.
//

import Foundation

enum PostMapper {
    static func toDomain(_ dto: PostResponseDTO) -> Post {
        Post(
            id: dto.id,
            content: dto.content,
            dateOfCreated: dto.dateOfCreated,
            authorId: dto.authorId,
            authorFirstname: dto.authorFirstname,
            authorAge: dto.authorAge,
            companyId: dto.companyId,
            companyName: dto.companyName,
            hotCount: dto.hotCount,
            coldCount: dto.coldCount,
            myVote: dto.myVote,
            responseCount: dto.responseCount
        )
    }
}
