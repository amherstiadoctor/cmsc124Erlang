-module(chat).
-compile(export_all).

init_chat() ->
	Name1 = string:strip(io:get_line("Enter your Name: "), right, $\n),
    register(chat1,spawn(chat,chat1,[Name1])).

chat1(Name1) ->
    receive
        finished ->
            io:format("Your are now disconnected.~n");

        { chat2 , Chat2_Pid, Name2 } ->
            Chat2_Pid ! {chat1, Name1, io:get_line(io_lib:format("~s:   ", [Name1]))},
            % self() ! { chat2 , Chat2_Pid, Name2}, %added line
            chat1(Name1);

        { chat2 , Chat2_Pid, Name2, Message2 } ->
            if
                Message2 /= "bye\n" ->
                    io:format("~s:  ~s",[Name2, Message2]),
                    Chat2_Pid ! {chat1, Name1, io:get_line(io_lib:format("~s:   ", [Name1]))},
                    % self() ! { chat2 , Chat2_Pid, Name2}, %added line
                    chat1(Name1);
                Message2 == "bye\n" ->
                    io:format("~s:  bye~n",[Name2]),
                    Chat2_Pid ! finished,
                    io:format("Your partner disconnected. ~n"),
                    chat1(Name1)
            end
    end.

init_chat2( Chat1_Node ) ->
	Name2 = string:strip(io:get_line("Enter your Name: "), right, $\n),
    spawn(chat,chat2,[1 , Chat1_Node, Name2]).

chat2(0 , Chat1_Node, Name2) ->
    { chat1 , Chat1_Node } ! finished,
    io:format("Your partner disconnected. ~n");

chat2(1 , Chat1_Node, Name2) ->
    { chat1 , Chat1_Node } ! { chat2 , self (), Name2},
    receive
        finished ->
            io:format("Your are now disconnected.~n");

        {chat1, Name1, Message1} ->
            if
                Message1 /= "bye\n" ->
                    io:format("~s:  ~s",[Name1, Message1]),
                    { chat1 , Chat1_Node } ! { chat2 , self (), Name2, io:get_line(io_lib:format("~s:   ", [Name2]))},
                    chat2(2,Chat1_Node, Name2);
                Message1 == "bye\n" ->
                    chat2(0,Chat1_Node, Name2)
            end
    end;

chat2(2 , Chat1_Node, Name2) ->
    receive
        finished ->
            io:format("Your are now disconnected.~n");

        {chat1, Name1, Message1} ->
            if
                Message1 /= "bye\n" ->
                    io:format("~s:  ~s",[Name1, Message1]),
                    { chat1 , Chat1_Node } ! { chat2 , self (), Name2, io:get_line(io_lib:format("~s:   ", [Name2]))},
                    % self() ! { chat2 , Chat1_Node, Message1}, %added line
                    chat2(2,Chat1_Node, Name2);
                Message1 == "bye\n" ->
                    chat2(0,Chat1_Node, Name2)
            end
    end.

    %pong = chat1
    %ping = chat2