def update_all_pairs(context):
    #pair = [(ticker_x, ticker_y), (sid_x, sid_y), is_cointegrated, dif_list, ave, stdev]
    global all_pairs

    #for each pair
    for p in range(0, len(all_pairs)):
        ticker_x = all_pairs[p][0][0]
        ticker_y = all_pairs[p][0][1]

        #get history
        x_history = (context.stocks)[ticker_x][1]
        y_history = (context.stocks)[ticker_y][1]
        #get difference
        dif_list = []
        for i in range (0, len(x_history)):
            dif_list.append(x_history[i] - y_history[i])
        #get stdev
        stdev = np.std(dif_list)
        #get average
        ave = np.average(dif_list)
        #get cointegration
        is_cointegrated = are_cointegrated(x_history, y_history)
        #update information
        all_pairs[p] = [all_pairs[p][0], all_pairs[p][1], is_cointegrated, dif_list, ave, stdev]
        log.info(str(all_pairs[p]))

        
