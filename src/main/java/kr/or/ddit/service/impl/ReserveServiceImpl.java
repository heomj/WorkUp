package kr.or.ddit.service.impl;

import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import kr.or.ddit.mapper.ReserveMapper;
import kr.or.ddit.service.ReserveService;
import kr.or.ddit.vo.ReserveVO;

@Service
public class ReserveServiceImpl implements ReserveService {

    @Autowired
    private ReserveMapper mapper;

    @Override
    public List<Map<String, Object>> getAllReserveList() { 
    	return mapper.getAllReserveList(); 
    }

    @Override
    public Map<String, Object> getMyTeamLeader(String empId) { 
    	return mapper.getMyTeamLeader(empId); 
    }

    @Override 
    public List<ReserveVO> getMyReserveList(String empId) { 
    	return mapper.getMyReserveList(empId); 
    }

    @Override 
    public List<ReserveVO> getMtgRoomList() { 
    	return mapper.getMtgRoomList(); 
    }

    @Override 
    public List<String> getReservedTimes(Map<String, Object> map) { 
    	return mapper.getReservedTimes(map); 
    }
    
    @Override
    public int checkRoomOverlap(ReserveVO reserveVO) { 
    	return mapper.checkRoomOverlap(reserveVO); 
    }

    @Override
    public int insertMtgRoomReserve(ReserveVO reserveVO) {
        if (this.checkRoomOverlap(reserveVO) > 0) return -1;
        return mapper.insertMtgRoomReserve(reserveVO);
    }
    
    @Override
    public int updateMtgRoomReserve(ReserveVO reserveVO) {
        if (this.checkRoomOverlap(reserveVO) > 0) return -1;
        return mapper.updateMtgRoomReserve(reserveVO);
    }
    
    @Override
    public int deleteMtgRoomReserve(String resId) { 
    	return mapper.deleteMtgRoomReserve(resId);
    }

    @Override
    public List<ReserveVO> getFixtList() { 
    	return mapper.getFixtList();
    }

    @Override
    public int checkFixtOverlap(ReserveVO reserveVO) { 
    	return mapper.checkFixtOverlap(reserveVO);
    }

    @Override 
    public int insertFixtReserve(ReserveVO reserveVO) {
        if (this.checkFixtOverlap(reserveVO) > 0) return -1;
        
        int result = mapper.insertFixtReserve(reserveVO);
        
        return result;
    }
    @Override
    public int updateFixtReserve(ReserveVO reserveVO) {
        if (this.checkFixtOverlap(reserveVO) > 0) return -1;
        return mapper.updateFixtReserve(reserveVO);
    }
    
    @Override
    public int deleteFixtReserve(String resId) { 
    	return mapper.deleteFixtReserve(resId); 
    }

    @Override
    public List<ReserveVO> getPendingApprovalList(String empId) { 
    	return mapper.getPendingApprovalList(empId); 
    }

    @Override
    public int approveReserve(Map<String, String> paramMap) { 
        return mapper.approveReserve(paramMap); 
    }

    @Override
    public List<ReserveVO> getAdminRoomList() { 
    	return mapper.getAdminRoomList(); 
    }

    @Override
    public List<ReserveVO> getAdminFixtList() { 
    	return mapper.getAdminFixtList(); 
    }

    @Override
    public int insertAdminRoom(ReserveVO reserveVO) { 
    	return mapper.insertAdminRoom(reserveVO); 
    }

    @Override
    public int updateAdminRoom(ReserveVO reserveVO) { 
    	return mapper.updateAdminRoom(reserveVO); 
    }

    @Transactional 
    @Override
    public int deleteAdminRoom(int rmNo) { 
        return mapper.deleteAdminRoom(rmNo); 
    }

    @Override
    public int insertAdminFixt(ReserveVO reserveVO) { 
    	return mapper.insertAdminFixt(reserveVO); 
    }

    @Override
    public int updateAdminFixt(ReserveVO reserveVO) { 
    	return mapper.updateAdminFixt(reserveVO); 
    }

    @Transactional
    @Override
    public int deleteAdminFixt(int fixtNo) { 
        return mapper.deleteAdminFixt(fixtNo); 
    }
}