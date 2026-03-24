package kr.or.ddit.vo;

import lombok.Data;

@Data
public class SalaryBaseVO {
    private int baseId;
    private String empJbgdCode;
    private int baseMin;
    private int baseMax;
}
