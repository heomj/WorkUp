package kr.or.ddit.vo;

import lombok.Data;

@Data
public class SalaryItemVO {
    private int itemId;
    private String itemNm;
    private String itemType;
    private String itemTaxable;
}
