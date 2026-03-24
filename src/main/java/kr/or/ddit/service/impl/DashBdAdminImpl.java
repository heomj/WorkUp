package kr.or.ddit.service.impl;

import kr.or.ddit.mapper.DashBdAdminMapper;
import kr.or.ddit.service.DashBdAdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class DashBdAdminImpl implements DashBdAdminService {

    @Autowired
    DashBdAdminMapper dashBdAdminMapper;

    @Override
    public Long budget() {
        return this.dashBdAdminMapper.budget();
    }

    @Override
    public int emp() {
        return this.dashBdAdminMapper.emp();
    }

    @Override
    public int proj() {
        return this.dashBdAdminMapper.proj();
    }

    @Override
    public int complaint() {
        return this.dashBdAdminMapper.complaint();
    }
}
