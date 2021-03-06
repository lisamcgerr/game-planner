class SessionsController < ApplicationController

    def index
        @sessions = Session.public_sessions
    end

    def new
        @session = Session.new
    end

    def create
        @session = Session.new(session_params)

        if @session.save
            user_session = UserSession.new(user_id: session[:user_id], session_id: @session.id)
            if user_session.save
                redirect_to session_path(@session)
            else
                render :new
            end
        else
            render :new
        end
    end
    

    def show
        @user_session = UserSession.new
        @session = Session.find_by(id: params[:id])
    end

    def edit
        @session = Session.find_by(id: params[:id])
    end

    def update
        session = Session.find_by(id: params[:id])

        if session.update(session_params)
                redirect_to session_path(session)
        else
            render :edit
        end
    end

    def remove_user
        @session = Session.find_by(id: params[:id])
        @user_sessions = @session.user_sessions
        # byebug
    end

    def join_session

        session = Session.find_by(id: params[:id])
        user_session = session.user_sessions.build(user_id: current_user.id)

        if user_session.save
            flash.alert = []
            flash.alert << ["Welcome to the session!"]
            redirect_to session_path(session)
        else
            flash.alert = []
            flash.alert << user_session.errors.full_messages
            redirect_to session_path(session)
        end
    end

    private
    def session_params
        params["session"]["date"] = generate_date(params) 
        params["session"]["public"] = true_or_false(params)

        params.require(:session).permit(:date, :game_id, :public, :title)
    end

    def generate_date(params)
        date = DateTime.new(params["session"]["date(1i)"].to_i,
        params["session"]["date(2i)"].to_i,
        params["session"]["date(3i)"].to_i,
        params["session"]["date(4i)"].to_i,
        params["session"]["date(5i)"].to_i
      )
    end

    def true_or_false(params)
        if params["session"]["public"].to_i == 1
            true
        else
            false
        end
    end
end
