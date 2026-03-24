package kr.or.ddit.vo;

import lombok.Data;

import java.util.Date;

@Data
public class EmpAvtVO {
    private int empId;           // 사원 번호
    private int avtNo;           // 아바타 번호
    private String ownAvtWearYn; // 착용 여부 (Y/N)
    private String ownAvtYn;     // 삭제여부 (Y/N)
    private Date ownAvtDt;       // 구매/획득 날짜

    private String avtNm; // 아바타명
    private String avtSaveDt;  // 저장경로
    private String avtSaveNm; // 저장파일명
    private String avtONm;  // 원본파일명
}
