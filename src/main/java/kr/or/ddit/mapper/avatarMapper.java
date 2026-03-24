package kr.or.ddit.mapper;

import kr.or.ddit.vo.AvatarVO;
import kr.or.ddit.vo.EmpAvtVO;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface avatarMapper {
    // 전체 아바타 List 불러오기(처음 불러왔을 때)
    public List<AvatarVO> getallavtlist(String sortSelect, String cate);

    // 아바타 구매
    public int butavt(EmpAvtVO vo);

    // 아바타 구매시 보유중인가
    public EmpAvtVO checkavt(EmpAvtVO vo);

    // 구매시 마일리지 업데이트
    public void updatemlg(EmpAvtVO vo);

    // 내가 구매한 아바타 List
    public List<EmpAvtVO> myavtlist(int empid);

    // 아바타 삭제하기
    public int deleteavt(EmpAvtVO empAvtVO);

    // 현재 내가 입고 있는 아바타
    public int wear(int empId);

    // 아바타 교체
    public int wearavt(EmpAvtVO empAvtVO);

    public int delete(AvatarVO vo);

    public int update(AvatarVO vo);

    public int insert(AvatarVO vo);
}
