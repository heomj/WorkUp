package kr.or.ddit.vo;

import lombok.Data;



@Data
public class GooroomeeVO {

    private int onmtgRmNo;
    private String onmtgRmTtl;
    private String onmtgRmUrl;
    private int onmtgRmMaxNope;
    private String onmtgRmPswd;
    private String onmtgRmBgngDt; //Date를 못읽어서 String으로 받음
    private String onmtgRmEndDt;//Date를 못읽어서 String으로 받음
    private String onmtgRmHr;//Date를 못읽어서 String으로 받음


    private String roomId;
    private String userNickname;
    private String roomType;
    private String roomUrlId;
    private String  roomTitle;
    private int  maxJoinCnt;
    private int  currJoinCnt;
    private String startDate;//Date를 못읽어서 String으로 받음
    private String endDate;//Date를 못읽어서 String으로 받음
    private boolean  isDefinePasswd;


}
