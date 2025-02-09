-- CALCULATE GPM, NPM, and ETR (INDIVIDUAL TAXPAYERS)
select 
    a.NPWP,  -- Taxpayer Identification Number
    d.Nama_WP,  -- Taxpayer Name
    e.year_nbr,  -- Tax Year
    a.JML_PU,  -- Total Revenue (Pendapatan Usaha)
    a.JML_HPP,  -- Cost of Goods Sold (Harga Pokok Penjualan)
    a.JML_LABA_RUGI_USAHA,  -- Business Profit or Loss
    a.JML_BIAYA_USAHA,  -- Total Business Expenses
    a.JML_PH_NETO,  -- Net Business Income
    a.JML_PPH,  -- Income Tax Payable (Pajak Penghasilan Terutang)

    -- Aggregated values from related tables
    SUM(b.JML_PU) as JML_PU46,  -- Total Revenue under PP 46 (Simplified Tax Regime)
    SUM(b.JML_PPH_FINAL_DIBYR) as PPH45Bayar,  -- Final Tax Paid under PP 45
    c.JML_PU_Dagang,  -- Revenue from Trading Activities
    c.JML_PH_Neto_Dagang,  -- Net Income from Trading Activities

    -- Calculating Gross Profit Margin (GPM)
    case 
        when a.JML_PU > 0 then (a.JML_PU - a.JML_HPP) / a.JML_PU 
        else null 
    end as Gross_Profit_Margin, 

    -- Calculating Net Profit Margin (NPM)
    case 
        when a.JML_PU > 0 then a.JML_PH_NETO / a.JML_PU 
        else null 
    end as Net_Profit_Margin, 

    -- Calculating Effective Tax Rate (ETR)
    case 
        when a.JML_PH_NETO > 0 then a.JML_PPH / a.JML_PH_NETO 
        else null 
    end as Effective_Tax_Rate

from SPT_OP_HIT_PH_NETO_DN_PEMBUKUAN a
-- Joining with the PP 46 tax data table (simplified tax regime for small businesses)
join SPT_OP_PP46 b 
    on a.ID_SPT = b.ID_SPT 
-- Joining with business income calculations under the recording system
join SPT_OP_HIT_PH_NETO_DN_PENCATATAN c 
    on a.ID_SPT = c.ID_SPT 
    and b.ID_SPT = c.ID_SPT
-- Joining with taxpayer details
join wp d 
    on a.NPWP = d.NPWP
-- Joining with the tax year dimension table
join DIM_MS_THN_PJK e 
    on e.ID_MS_Th_PJK = a.ID_MS_TH_PJK 
    and e.ID_MS_Th_PJK = b.ID_MS_TH_PJK 
    and e.ID_MS_Th_PJK = c.ID_MS_TH_PJK
-- Filtering by industry classification codes
Where d.KD_KLU in ($${SUnique concatenate(KLUNEW)}$$)

-- Grouping by taxpayer, tax year, and other relevant fields
group by 
    a.NPWP, 
    d.Nama_WP, 
    e.year_nbr, 
    a.JML_PU, 
    a.JML_HPP, 
    a.JML_LABA_RUGI_USAHA, 
    a.JML_BIAYA_USAHA, 
    a.JML_PH_NETO, 
    a.JML_PPH,
    c.JML_PU_Dagang,
    c.JML_PH_Neto_Dagang;