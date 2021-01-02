//
//  AppInfo.swift
//  Proteusific
//
//  Created by Adam Jansch on 02/01/2021.
//

import Foundation

struct AppInfo {
	enum Section: Int, CaseIterable, Identifiable {
		case banner
		case app
		case developer		// Should only be displayed in DEBUG mode
		case about
		
		static var allSections: [Section] {
			var sections = allCases
			
			if ProteusificApp.isDebug == false {
				sections.removeAll(where: { $0.debugOnly })
			}
			
			return sections
		}
		
		var id: Int {
			return rawValue
		}
		
		var title: String? {
			switch self {
			case .app:
				return "App"
			case .developer:
				return "Developer"
			case .about:
				return "About"
			default:
				return nil
			}
		}
		
		var options: [Option] {
			switch self {
			case .banner:
				return [.banner]
			case .app:
				return [.settings, .getHelp]
			case .developer:
				return [.developerTools]
			case .about:
				return [.acknowledgements, .terms, .privacyPolicy]
			}
		}
		
		var debugOnly: Bool {
			switch self {
			case .developer:
				return true
			default:
				return false
			}
		}
	}
	
	enum Option: Int, Identifiable {
		case acknowledgements
		case banner
		case developerTools
		case getHelp
		case privacyPolicy
		case settings
		case terms
		
		var id: Int {
			return rawValue
		}
		
		var mainText: String {
			switch self {
			case .acknowledgements:
				return "Acknowledgements"
			case .developerTools:
				return "Developer Tools"
			case .getHelp:
				return "Get Help"
			case .privacyPolicy:
				return "Privacy Policy"
			case .settings:
				return "Settings"
			case .terms:
				return "Terms & Conditions"
			default:
				return ""
			}
		}
	}
}
