package kr.or.ddit.chatbot.project.service.impl;

import kr.or.ddit.vo.project.ProjectVO;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;

@Mapper
public interface WorkUpAiProjectMapper {
    // (2)번 프로젝트
    public List<ProjectVO> project(int empId);
}
