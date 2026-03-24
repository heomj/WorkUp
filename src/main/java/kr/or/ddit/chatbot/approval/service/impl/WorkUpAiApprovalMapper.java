package kr.or.ddit.chatbot.approval.service.impl;

import kr.or.ddit.vo.project.ProjectVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;


/**
 * 
 * 전자결재 AI챗봇 매퍼(5번-전자결재)
 */


@Mapper
public interface WorkUpAiApprovalMapper {
    // (5)번 프로젝트
    public List<ProjectVO> project(int empId);
}
