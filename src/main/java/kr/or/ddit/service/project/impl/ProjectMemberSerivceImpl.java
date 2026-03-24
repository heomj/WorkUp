package kr.or.ddit.service.project.impl;

import kr.or.ddit.mapper.project.ProjectMemberMapper;
import kr.or.ddit.service.project.ProjectMemberSerivce;
import kr.or.ddit.vo.project.PrtpntVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Slf4j
@Service
public class ProjectMemberSerivceImpl implements ProjectMemberSerivce {

    @Autowired
    private ProjectMemberMapper projectMemberMapper;


    // 프로젝트 참여자 리스트 조회
    @Override
    public List<PrtpntVO> memberStatus(int projNo) {
        return this.projectMemberMapper.memberStatus(projNo);
    }

    @Override
    public List<PrtpntVO> memberTaskStatus(int projNo) {
        return this.projectMemberMapper.memberTaskStatus(projNo);
    }
}
