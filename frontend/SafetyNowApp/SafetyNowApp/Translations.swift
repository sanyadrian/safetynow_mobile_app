import Foundation

struct Translations {
    static let hazardTranslations: [String: [String: String]] = [
        "en": [
            "Fire": "Fire",
            "Slip": "Slip",
            "Fall": "Fall",
            "Chemical": "Chemical",
            "Electrical": "Electrical",
            "Machine": "Machine",
            "Noise": "Noise",
            "Ergonomics": "Ergonomics",
            "Confined Space": "Confined Space",
            "Working at Heights": "Working at Heights",
            "Airborne Hazards Safety": "Airborne Hazards Safety",
            "Bloodborne Pathogens": "Bloodborne Pathogens"
        ],
        "fr": [
            "Fire": "Feu",
            "Slip": "Glissade",
            "Fall": "Chute",
            "Chemical": "Chimique",
            "Electrical": "Électrique",
            "Machine": "Machine",
            "Noise": "Bruit",
            "Ergonomics": "Ergonomie",
            "Confined Space": "Espace Confiné",
            "Working at Heights": "Travail en Hauteur",
            "Airborne Hazards Safety": "Sécurité des Hazards Aériens",
            "Bloodborne Pathogens": "Pathogènes par voie sanguine"
        ],
        "es": [
            "Fire": "Fuego",
            "Slip": "Resbalón",
            "Fall": "Caída",
            "Chemical": "Químico",
            "Electrical": "Eléctrico",
            "Machine": "Máquina",
            "Noise": "Ruido",
            "Ergonomics": "Ergonomía",
            "Confined Space": "Espacio Confinado",
            "Working at Heights": "Trabajo en Altura",
            "Airborne Hazards Safety": "Seguridad de los Riesgos Aéreos",
            "Bloodborne Pathogens": "Riesgos por contacto con fluidos corporales"
        ]
    ]
    
    static let industryTranslations: [String: [String: String]] = [
        "en": [
            "Construction": "Construction",
            "Manufacturing": "Manufacturing",
            "Healthcare": "Healthcare",
            "Transportation": "Transportation",
            "Agriculture": "Agriculture",
            "Mining": "Mining",
            "Oil and Gas": "Oil and Gas",
            "Utilities": "Utilities",
            "Retail": "Retail",
            "Hospitality": "Hospitality",
            "Environmental": "Environmental"
        ],
        "fr": [
            "Construction": "Construction",
            "Manufacturing": "Fabrication",
            "Healthcare": "Santé",
            "Transportation": "Transport",
            "Agriculture": "Agriculture",
            "Mining": "Exploitation Minière",
            "Oil and Gas": "Pétrole et Gaz",
            "Utilities": "Services Publics",
            "Retail": "Commerce de Détail",
            "Hospitality": "Hôtellerie",
            "Environmental": "Environnement"
        ],
        "es": [
            "Construction": "Construcción",
            "Manufacturing": "Fabricación",
            "Healthcare": "Salud",
            "Transportation": "Transporte",
            "Agriculture": "Agricultura",
            "Mining": "Minería",
            "Oil and Gas": "Petróleo y Gas",
            "Utilities": "Servicios Públicos",
            "Retail": "Comercio Minorista",
            "Hospitality": "Hostelería",
            "Environmental": "Ambiental"
        ]
    ]
    
    static func translateHazard(_ hazard: String, language: String) -> String {
        return hazardTranslations[language]?[hazard] ?? hazard
    }
    
    static func translateIndustry(_ industry: String, language: String) -> String {
        return industryTranslations[language]?[industry] ?? industry
    }
} 