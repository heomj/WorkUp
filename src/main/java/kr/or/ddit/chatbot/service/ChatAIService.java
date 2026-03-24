package kr.or.ddit.chatbot.service;

import kr.or.ddit.service.impl.CustomUser;

public interface ChatAIService {

	public String buildUser(String question, CustomUser customUser);

	public String buildSystem(String question, CustomUser customUser);

}
