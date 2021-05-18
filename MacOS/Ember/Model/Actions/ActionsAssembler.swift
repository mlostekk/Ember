// Copyright (c) 2021 Nomad5. All rights reserved.

import Foundation

protocol ActionsAssembler {
    func resolve() -> Actions
}

extension ActionsAssembler where Self: Assembler
{
    private func createActions() -> Actions {
        let initial = Actions()
        register(initial)
        return initial
    }

    func resolve() -> Actions {
        let actions = get(type: Actions.uniqueKey) as? Actions
        return actions ?? createActions()
    }
}