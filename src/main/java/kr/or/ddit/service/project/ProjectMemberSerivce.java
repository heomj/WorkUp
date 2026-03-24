package kr.or.ddit.service.project;

import kr.or.ddit.vo.project.PrtpntVO;

import java.util.List;
import java.util.Map;

public interface ProjectMemberSerivce {

    // 프로젝트 참여자 리스트 조회
    public List<PrtpntVO> memberStatus(int projNo);

    // 업무능력별 참여자 리스트 조회
    public List<PrtpntVO> memberTaskStatus(int projNo);


}
