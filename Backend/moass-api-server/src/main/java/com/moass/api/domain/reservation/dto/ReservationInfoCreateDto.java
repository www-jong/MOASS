package com.moass.api.domain.reservation.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;
import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class ReservationInfoCreateDto {

        private Integer reservationId;

        private String infoName;

        private List<Integer> infoTimes;

        private LocalDate infoDate;

        private List<String> infoUsers;
}