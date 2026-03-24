package kr.or.ddit.service;

public interface DashBdAdminService {

    // 남은 예산
    public Long budget();

    // 전체 사원 수
    public int emp();

    // 진행하고 ㅣㅇㅆ는 프로젝트 수
    public int proj();

    // 이번달 신고수
    public int complaint();
}
