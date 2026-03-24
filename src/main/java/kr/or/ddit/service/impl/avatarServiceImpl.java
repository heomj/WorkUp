package kr.or.ddit.service.Impl;

import kr.or.ddit.mapper.avatarMapper;
import kr.or.ddit.service.avatarService;
import kr.or.ddit.vo.AvatarVO;
import kr.or.ddit.vo.EmpAvtVO;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
public class avatarServiceImpl implements avatarService {

    @Autowired
    avatarMapper avtmapper;

    @Override
    public List<AvatarVO> getallavtlist(String sortSelect, String cate) {
        return this.avtmapper.getallavtlist(sortSelect,cate);
    }

    @Transactional
    @Override
    public int butavt(EmpAvtVO vo) {

        // 사려고 하는 아바타가 갖고 있나 체크하는
        EmpAvtVO ch = this.avtmapper.checkavt(vo) ;

        if(ch != null) {
            return 2;
        }

        log.info("왜 0임? : {}", vo);

        // 성공하는..
        int result = this.avtmapper.butavt(vo);

        this.avtmapper.updatemlg(vo);

        return result;
    }

    // 내가 구매한 아바타 List
    @Override
    public List<EmpAvtVO> myavtlist(int empid) {
        return this.avtmapper.myavtlist(empid);
    }

    // 아바타 삭제하기
    @Override
    public int deleteavt(EmpAvtVO empAvtVO) {
        return this.avtmapper.deleteavt(empAvtVO);
    }

    @Transactional
    @Override
    public int wearavt(EmpAvtVO empAvtVO) {
        this.avtmapper.wear(empAvtVO.getEmpId());

        return this.avtmapper.wearavt(empAvtVO);
    }

    @Override
    public int update(AvatarVO vo) {
        return this.avtmapper.update(vo);
    }

    @Override
    public int insert(AvatarVO vo) {
        return this.avtmapper.insert(vo);
    }

    @Override
    public int delete(AvatarVO vo) {
        return this.avtmapper.delete(vo);
    }


}
