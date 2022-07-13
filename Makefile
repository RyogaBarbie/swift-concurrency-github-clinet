.PHONY: setup
setup:
	touch SwiftConcurrencySample/Core/Env/ENV.swift
	./BuildEnv.sh ./.env SwiftConcurrencySample/Core/Env/ENV.swift