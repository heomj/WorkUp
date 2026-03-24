package kr.or.ddit.mapper;

import kr.or.ddit.vo.EmployeeVO;
import kr.or.ddit.vo.SurveyVO;
import org.apache.ibatis.annotations.MapKey;
import org.apache.ibatis.annotations.Mapper;

import java.util.List;
import java.util.Map;

@Mapper
public interface SurveyMapper {

    // [관리자 페이지]
    // 설문 마스터 정보 저장
    public int insertSurveyMaster(SurveyVO surveyVO);

    // 설문 문항 저장
    public int insertQuestion(SurveyVO questionVO);

    // 설문 문항별 보기 저장
    public int insertItem(SurveyVO itemVO);

    // [사용자 페이지]
    // 참여 가능한 설문
    public List<SurveyVO> newList(int loginId);

    // 참여한 설문
    public List<SurveyVO> mineList(int loginId);

    // 종료된 설문
    public List<SurveyVO> closedList(int loginId);

    // 설문 상세 조회
    public SurveyVO surveyDetail(int srvyNo);

    // 설문 답변 저장
    public int insertAnswer(SurveyVO surveyVO);

    // 참여자 수 증가
    public int incrementSurveyNope(int srvyNo);

    // 전체 설문 리스트 조회
    public SurveyVO statsData(int srvyNo);

    // 마일리지 지급
    public int addMlg(EmployeeVO empVO);

    // 전사원 id 가져오기
    public List<EmployeeVO> SurveyAllEmpIds();

    
    // [관리자 페이지] ------------------------------------------------
    // 설문 리스트
    public List<SurveyVO> allList();

    // 종료 상태로 변경
    public int updateStts();

    // 설문 수정
    public int updateSurvey(SurveyVO surveyVO);

    // 설문 삭제
    public int deleteSurveys(List<SurveyVO> srvyNo);

    // 설문 상태 일괄 종료로 변경
    public int updateSttsSurvey(List<SurveyVO> surveyList);


    // 통계
    public SurveyVO surveyStats();

    // 평균 참여율
    public SurveyVO avgSurvey();

    @MapKey("name")
    public List<Map<String, Object>> deptStats(int srvyNo);

    @MapKey("name")
    public List<Map<String, Object>> rankStats(int srvyNo);

    // 재직 사원 총 인원수
    public int totalEmpCount();

    // 개별 응답 상세
    public List<Map<String, Object>> individualAnswer(Long srvyNo);

}
