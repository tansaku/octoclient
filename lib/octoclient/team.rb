module OctoClient
  class TeamAPI

    # https://developer.github.com/v3/orgs/teams/#list-user-teams
    def self.user_teams_url(user_token)
      "#{API_URL}/user/teams?access_token=#{user_token}"
    end

    # this and above not currently tested 
    # used for unsupported /teams feature
    def self.user_teams(user_token)
      OctoClient::get user_teams_url(user_token)
    end

    # not currently used
    # https://developer.github.com/v3/orgs/teams/#list-team-members
    def self.team_members_url(team_id)
      "#{API_URL}/teams/#{team_id}/members#{ACCESS_PARAMS}"
    end

    # https://developer.github.com/v3/orgs/teams/#list-teams
    def self.org_teams_url(org_name)
      "#{API_URL}/orgs/#{org_name}/teams#{ACCESS_PARAMS}"
    end

    # https://developer.github.com/v3/orgs/teams/#create-team
    def self.create_team(org_name, team_name, repo_name, permission = 'pull')
      post_body = %Q{{"name": "#{team_name}"}}
      repo_chunk = %Q{,
          "permission": "#{permission}",
          "repo_names": [
            "#{repo_name}"
          ]
      }
      OctoClient::post org_teams_url(org_name), post_body
    end

    # https://developer.github.com/v3/orgs/teams/#get-team-member
    def self.team_member_url(team_id, username)
      "#{API_URL}/teams/#{team_id}/members/#{username}#{ACCESS_PARAMS}"
    end

    # https://developer.github.com/v3/orgs/teams/#add-team-member
    def self.add_team_member(team_id, username)
      OctoClient::put team_member_url(team_id, username), ''
    end
  end
end