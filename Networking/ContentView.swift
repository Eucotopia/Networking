//
//  ContentView.swift
//  Networking
//
//  Created by 李伟 on 2024/9/17.
//

import SwiftUI

struct ContentView: View {
    @State private var user: GitHubUser?
    var body: some View {
        VStack(spacing: 20) {
            AsyncImage(url: URL(string: user?.avatarUrl ?? "")){ image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .foregroundStyle(.secondary)
            }
            .frame(width: 120,height: 120)

            Text(user?.login ?? "Login Placeholder")

            Text(user?.bio ?? "Bio Placeholder")
                .padding()
            Spacer()
        }
        .padding()
        .task {
            do {
                user = try await getUser()
            } catch GitHubError.invalidURL{
                print("invalid URL")
            } catch GitHubError.invalidResponse {
                print("invalid response")
            } catch GitHubError.invalidData {
                print("invalid data")
            } catch {
                print("unexpected error")
            }
        }
    }

    func getUser() async throws -> GitHubUser {

        let endpoint = "https://api.github.com/users/Eucotopia"

        // 必须是有效的 url 地址
        guard let url = URL(string: endpoint) else {
            throw GitHubError.invalidURL
        }

        let (data,response) = try await URLSession.shared.data(from: url)

        // response 既需要是 HTTPURLResponse类型，同时 statusCode 也需要等于 200
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw GitHubError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()

            // avatar_url -> avatarUrl
            decoder.keyDecodingStrategy = .convertFromSnakeCase

            return try decoder.decode(GitHubUser.self, from: data)
        } catch {
            throw GitHubError.invalidData
        }
    }
}

#Preview {
    ContentView()
}


struct GitHubUser: Codable {
    let login: String
    let avatarUrl: String
    let bio: String
}


enum GitHubError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
