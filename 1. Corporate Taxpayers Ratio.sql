-- CALCULATE GPM, NPM, and ETR (CORPORATE TAXPAYERS)
select 
    a.NPWP,  -- Taxpayer Identification Number
    c.Nama_WP,  -- Taxpayer Name
    c.KD_KLU,  -- Industry Classification Code
    b.year_nbr,  -- Tax Year Number
    a.JML_PU,  -- Total Revenue (Pendapatan Usaha)
    a.JML_HPP,  -- Cost of Goods Sold (Harga Pokok Penjualan)
    a.JML_BUL,  -- Total Other Income (Penghasilan Usaha Lainnya)
    a.JML_PH_NETO_DU,  -- Net Business Income (Dari Usaha)
    a.JML_PH_DLU,  -- Net Income from Other Sources
    a.JML_BDLU,  -- Other Deductible Expenses
    a.JML_PH_NETO_DLU,  -- Net Income from Non-Business Sources
    a.JML_PH_NETO_KOMERSIAL_DN,  -- Net Commercial Income (Domestic)
    a.JML_PH_NETO_KOMERSIAL_LN,  -- Net Commercial Income (Foreign)
    a.JML_PH_NETO_KOMERSIAL,  -- Total Net Commercial Income
    a.JML_PH_FINAL_DAN_TIDAK_OBJEK_PJK,  -- Final and Non-Taxable Income
    d.JML_pkp,  -- Taxable Income (Penghasilan Kena Pajak)
    d.JML_PPH_TERUTANG,  -- Income Tax Payable

    -- Calculate Gross Profit Margin
    case 
        when a.JML_PU > 0 then (a.JML_PU - a.JML_HPP) / a.JML_PU
        else null 
    end as Gross_Profit_Margin,

    -- Calculate Net Profit Margin
    case 
        when a.JML_PU > 0 then a.JML_PH_NETO_KOMERSIAL / a.JML_PU
        else null 
    end as Net_Profit_Margin,

    -- Calculate Effective Tax Rate
    case 
        when a.JML_PH_NETO_KOMERSIAL > 0 then d.JML_PPH_TERUTANG / a.JML_PH_NETO_KOMERSIAL
        else null 
    end as Effective_Tax_Rate

from SPT_BADAN_PENGHITUNGAN_NETO_FISKAL a
-- Join with the main tax report table to get taxable income data
join SPT_BADAN_INDUK d 
    on a.NPWP = d.npwp 
    and a.ID_SPT = d.ID_SPT 
-- Join with the tax year dimension table
join DIM_MS_THN_PJK b 
    on a.ID_ms_th_pjk = b.ID_ms_th_pjk 
    and b.ID_ms_th_pjk = d.ID_ms_th_pjk
-- Join with the taxpayer table to get taxpayer details
join wp c 
    on c.NPWP = a.NPWP
-- Filter by industry classification codes
Where c.KD_KLU in ($${SUnique concatenate(KLUNEW)}$$);