package kr.or.ddit.vo;

import lombok.Data;

@Data
public class AttendanceTypeVO {
    private int attTypeId;
    private int empId;
    private String attReqType;

    // 쿼리 결과를 담기 위한 프로퍼티
    private String type;       // AS TYPE
    private String appDate;    // AS APP_DATE
    private String appEndDate; // AS APP_END_DATE
    private double totalDays;  // AS TOTAL_DAYS
    private String reason;     // AS REASON
    private String status;     // AS STATUS
    private String vctDocCd;   //

    // 달력 신청서 결과를 담기 위한 프로퍼티
    private String eventDate;  // YYYY-MM-DD
    private String eventType;  // overtime, vacation, trip
    private String eventLabel; // 💪 초과, 🌴 휴가, ✈️ 출장
    private String formStatus;     // 결재완료
}
