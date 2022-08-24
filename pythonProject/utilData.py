def compute_loss_SL (in_df_position) :

    mask_sl = in_df_position['Reason'] == 'DEAL_REASON_SL'
    df_sl = in_df_position[mask_sl]
    df_sl = df_sl[['Profit', 'Swap', 'Commission']]
    df_sl = df_sl.sum(axis=1)
    return df_sl
def compute_reward_tp(in_df_position) :
    mask_tp = in_df_position['Reason'] == 'DEAL_REASON_TP'
    df_tp = in_df_position[mask_tp]
    df_tp = df_tp[['Profit', 'Swap', 'Commission']]
    df_tp = df_tp.sum(axis=1)
    return df_tp
def compute_profit_other(in_df_position) :
    mask_tp = in_df_position['Reason'] == 'DEAL_REASON_TP'
    mask_sl = in_df_position['Reason'] == 'DEAL_REASON_SL'
    df_other = in_df_position[~mask_tp & ~mask_sl]
    df_other = df_other[['Profit', 'Swap', 'Commission']]
    df_other = df_other.sum(axis=1)
    return df_other
