package kr.or.ddit.service;

import kr.or.ddit.vo.*;
import kr.or.ddit.vo.project.ProjectVO;

import java.util.List;
import java.util.Map;

public interface ApprovalService {


    //전체 행의 수(검색시 검색 반영)
    public int getTotal(Map<String, Object> map);
    //결재대기 행의 수
    public int getPendingTotal(Map<String, Object> map);

    //결재문서 목록 가져오기(사용자)
    public List<ApprovalVO> list(Map<String, Object> map);

    //(관리자)전체 결재문서 목록 가져오기
    public List<ApprovalVO> allList(Map<String, Object> map);

    //결재대기 목록 가져오기
    public List<ApprovalVO> pendingList(Map<String, Object> map);

    //결재선 가져오기
    public List<AprvLineVO> getAprvLine(int aprvNo);

    //결재문서 본문 가져오기 수정
    public ApprovalVO getCompleteDoc(int aprvNo);

    //승인/반려 시 결재선 업데이트
    public int aprvLineUpdate(AprvLineVO aprvLineVO);

    //승인/반려 시 결재문서 상태 업데이트
    public int updateAprvStatus(AprvLineVO aprvLineVO);

    //부서 문서함 문서 개수
    public int getDeptAprvTotal(Map<String, Object> map);

    //부서 문서 리스트 가져오기
    public List<ApprovalVO> deptAprvlist(Map<String, Object> map);

    //신청한(미결재) 초과근무 신청 내역 불러오기
    public List<OvertimeDocumentVO> getOvertimeDocumentVOList(int empId);

    //신청한(미결재) 휴가 신청 목록 가져오기
    public List<VacationDocumentVO> getVacationDocumentVOList(int empId);

    //신청한(미결재) 출장신청 목록 가져오기
    public List<TripDocumentVO> getTripDocumentVOList(int empId);

    //결재문서 insert
    public int insertAprv(ApprovalVO approvalVO);
    
    //초과, 출장, 휴가 상태 업데이트
    public int updateAttAprv(ApprovalVO approvalVO);

    //결재선 insert
    public int insertAprvLineVOList(List<AprvLineVO> list);

    //상세문서(근태만) 결재완료/반려 업데이트
    public int updateDocStts(AprvLineVO aprvLineVO);

    //휴가 돌려주기
    public int returnUseVct(AprvLineVO aprvLineVO);

    //(관리자용) 전체 목록
    public int getTotalAll(Map<String, Object> map);

    /**
     * 관리자 페이지) 예산에서 전자결재 검색하기
     * @param map 검색조건
     * @return 전자결재 리스트
     */
    public List<ApprovalVO> searchBudgetAprvList(Map<String, Object> map);



    // 부서별 문서 건수 (도넛 차트용)
    public List<Map<String, Object>> getDeptDocCount();

    // 부서별 월별 결재문서량
    public List<Map<String, Object>> getMonthlyDeptVolume();

    //일반기안문 insert
    public int insertNmlDoc(ApprovalVO approvalVO);

    //(알람용)전자결재 번호로 사번 가져오기
    public ApprovalVO getDocWriterId(int aprvNo);

    //(알람용) 다음결재자 사번 가져오기
    public Integer getNextAprvLnId(int aprvNo);

    //결재 수신함에서 내가 결재한 문서 개수
    public int getPendingDoneTotal(Map<String, Object> map);

    //결재 수신함에서 내가 결재한 문서 리스트
    public List<ApprovalVO> getPendingDonedoneList(Map<String, Object> map);

    //업무 태그 용) 진행중 프로젝트
    public List<ProjectVO> getIngProjectList(int empId);


    //업무태그용) 완료된 프로젝트(3개월 이내)
    public List<ProjectVO> getDoneProjectList(int empId);

    //지출 품의를 위한 현재 부서별 예산 조회
    public List<BudgetDetailVO> getBudgetListByDept(int deptCd);

    //지출 품의서 마스터 테이블 insert
    public void insertExpndDoc(ApprovalVO approvalVO);

    //지출 품의서 상세 테이블 insert(한행씩)
    public void insertExpndDtl(ExpndDocVO expndDoc);

    //예산 사용량 업뎃(예산 비목 테이블 사용량 업뎃)
    public int updateBudgetUsage(ExpndDocVO dtl);

    //예산 사용 로그 남기기
    public void insertBudgetLog(BudgetLogVO logVO);

    //결재 반려되면 예산돌려주고 로그 찍어주기
    public void refundBudget(int aprvNo, int empId);

    //결재 문서 회수상태로 바꿈
    public int withdrawDocument(int aprvNo);

    //회수 개수 불러오기
    public int getWithDrawTotal(Map<String, Object> map);

    //회수 문서 리스트 불러오기
    public List<ApprovalVO> withDrawlist(Map<String, Object> map);

}
