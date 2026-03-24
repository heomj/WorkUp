package kr.or.ddit.service;

import kr.or.ddit.vo.AvatarVO;
import kr.or.ddit.vo.EmpAvtVO;

import java.util.List;

public interface avatarService {

    // 전체 아바타 List 불러오기(처음 불러왔을 때)
    public List<AvatarVO> getallavtlist(String sortSelect, String cate);

    // 아바타 구매
    public int butavt(EmpAvtVO vo);

    // 내가 구매한 아바타 List
    public List<EmpAvtVO> myavtlist(int empid);

    // 아바타 삭제하기
    public int deleteavt(EmpAvtVO empAvtVO);

    // 아바타 착용하기
    public int wearavt(EmpAvtVO empAvtVO);

    // 아바타 업데이트
    public int update(AvatarVO vo);
    // 아바타 등록
    public int insert(AvatarVO vo);
    // 아바타 삭제
    public int delete(AvatarVO vo);
}
