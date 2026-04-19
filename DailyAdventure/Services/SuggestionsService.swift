//
//  SuggestionsService.swift
//  DailyAdventure
//
//  Created by Henrique Bernardes on 19/04/26.
//


import Foundation

@MainActor
class SuggestionsService {
    static let shared = SuggestionsService()
    
    private let workSuggestions = [
        // Produtividade
        "Complete that project",
        "Review emails",
        "Team meeting",
        "Code review",
        "Plan tomorrow",
        "Update documentation",
        "Fix a bug",
        "Attend standup",
        // Organização
        "Clean up your desk",
        "Organize your files",
        "Update your to-do list",
        "Reply to pending messages",
        "Prepare for tomorrow's meeting",
        "Review your weekly goals",
        // Desenvolvimento
        "Learn something new",
        "Read an article",
        "Watch a tutorial",
        "Practice a new skill",
        "Work on a side project",
        "Write in your work journal"
    ]
    
    private let healthSuggestions = [
        // Exercício
        "Go for a walk",
        "Do a workout",
        "Stretch for 10 minutes",
        "Try yoga",
        "Go for a run",
        "Do 20 push-ups",
        "Take the stairs today",
        "Ride a bike",
        // Alimentação
        "Drink more water",
        "Eat healthy",
        "Cook a healthy meal",
        "Skip the junk food",
        "Have a nutritious breakfast",
        "Eat more vegetables today",
        // Bem-estar
        "Meditate",
        "Sleep early",
        "Take vitamins",
        "Take a deep breath",
        "Spend time outside",
        "Take a relaxing bath",
        "Disconnect from screens",
        "Practice gratitude"
    ]
    
    private let relationshipSuggestions = [
        // Amigos
        "Call a friend",
        "Text someone you miss",
        "Plan a hangout",
        "Send a funny meme",
        "Check in on an old friend",
        "Write a heartfelt message",
        // Família
        "Have dinner with family",
        "Call your parents",
        "Help a family member",
        "Share a memory with someone",
        "Plan a family activity",
        "Visit someone you care about",
        // Conexão
        "Listen to someone",
        "Share something",
        "Say thank you",
        "Give a compliment",
        "Be present in a conversation",
        "Express how you feel",
        "Do something kind for someone",
        "Write a letter to someone special"
    ]
    
    func getSuggestion(for category: QuestCategory) -> String {
        let suggestions: [String]
        
        switch category {
        case .work:
            suggestions = workSuggestions
        case .health:
            suggestions = healthSuggestions
        case .relationship:
            suggestions = relationshipSuggestions
        }
        
        return suggestions.randomElement() ?? "Add a quest"
    }
}
