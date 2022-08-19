.PHONY: setup
setup:
	touch SwiftConcurrencySample/Core/Env/ENV.swift
	./BuildEnv.sh ./.env SwiftConcurrencySample/Core/Env/ENV.swift

.PHONY: regenerate_secret
regenerate_secret:
	./BuildEnv.sh ./.env SwiftConcurrencySample/Core/Env/ENV.swift